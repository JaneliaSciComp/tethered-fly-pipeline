#!/usr/bin/env python

import argparse
import APT_interface as apt
import cv2
import cvc
import hdf5storage
import math
import movies
import numpy as np
import os
import re
import sys
import tarfile
import tempfile
import tensorflow as tf

from cvc import cvc
from enum import Enum


class _View(Enum):
    SIDE = 0
    FRONT = 1

    @classmethod
    def _argtype(cls, s):
        try:
            return cls[s]
        except KeyError:
            raise argparse.ArgumentTypeError(
                f"{s!r} is not a valid {cls.__name__}")

    def __str__(self):
        return self._name()

    def _neck_loc(self):
        return 5 + 10 * self.value

    def _name(self):
        if self.value == 0:
            return 'side'
        else:
            return 'front'

    def _default_crop_size(self):
        if self.value == 0:
            return (230, 350)
        else:
            return (350, 350)

    def _coord_param(self, coord_name):
        return 'reg_view{}_{}'.format(self.value+1, coord_name)


class FlyData:
    def __init__(self, flynum):
        self._flynum = flynum
        self._movies_list = []
        self._label_filename = None
        self._crop_locs = None

    def _add_movie(self, movie_filename):
        self._movies_list.append(movie_filename)

    def _set_label_file(self, label_filename):
        self._label_filename = label_filename

    def _set_crop_locs(self, crop_locs):
        self._crop_locs = crop_locs


def _adjust_crop_region(crop_region, crop_size, height, width):
    (x_left, x_right, y_top, y_bottom) = crop_region
    if x_right > width:
        x_left = width - crop_size[0] + 1
        x_right = width
    x_left = 1 if x_left < 1 else x_left
    if y_bottom > height:
        y_bottom = height
        y_top = height - crop_size[1] + 1
    y_top = 1 if y_top < 1 else y_top
    return [x_left, x_right, y_top, y_bottom]


def _classify_movie(mov_file, pred_fn, conf, crop_loc, model_type):
    cap = movies.Movie(mov_file)
    sz = (cap.get_height(), cap.get_width())
    n_frames = int(cap.get_n_frames())
    bsize = conf.batch_size
    flipud = False

    pred_locs = np.zeros([n_frames, conf.n_classes, 2])
    pred_ulocs = np.zeros([n_frames, conf.n_classes, 2])
    preds = np.zeros([n_frames, int(conf.imsz[0]//conf.rescale),
                      int(conf.imsz[1]//conf.rescale), conf.n_classes])
    pred_locs[:] = np.nan
    uconf = np.zeros([n_frames, conf.n_classes])

    to_do_list = []
    for cur_f in range(0, n_frames):
        to_do_list.append([cur_f, 0])

    n_list = len(to_do_list)
    n_batches = int(math.ceil(float(n_list) / bsize))
    cc = [c-1 for c in crop_loc]
    for cur_b in range(n_batches):
        cur_start = cur_b * bsize
        ppe = min(n_list - cur_start, bsize)
        all_f = apt.create_batch_ims(to_do_list[cur_start:(cur_start+ppe)], conf,
                                     cap, flipud, [None], crop_loc=cc)

        # base_locs, hmaps = pred_fn(all_f)
        ret_dict = pred_fn(all_f)
        base_locs = ret_dict['locs']
        hmaps = ret_dict['hmaps']
        if model_type == 'mdn':
            uconf_cur = ret_dict['conf_unet']
            ulocs_cur = ret_dict['locs_unet']
        else:
            uconf_cur = ret_dict['conf']
            ulocs_cur = ret_dict['locs']

        for cur_t in range(ppe):
            cur_entry = to_do_list[cur_t + cur_start]
            cur_f = cur_entry[0]
            xlo, xhi, ylo, yhi = crop_loc
            base_locs_orig = base_locs[cur_t, ...].copy()
            base_locs_orig[:, 0] += xlo
            base_locs_orig[:, 1] += ylo
            pred_locs[cur_f, :, :] = base_locs_orig[...]
            u_locs_orig = ulocs_cur[cur_t, ...].copy()
            u_locs_orig[:, 0] += xlo
            u_locs_orig[:, 1] += ylo
            pred_ulocs[cur_f, :, :] = u_locs_orig[...]
            preds[cur_f, ...] = hmaps[cur_t, ...]
            uconf[cur_f, ...] = uconf_cur[cur_t, ...]

        if cur_b % 20 == 19:
            sys.stdout.write('.')
        if cur_b % 400 == 399:
            sys.stdout.write('\n')

    if cap.is_open():
        cap.close()

    return pred_locs, preds, pred_ulocs, uconf


def _extract_flynum_from_filename(fn):
    try:
        dirname = os.path.normpath(fn)
        dir_parts = dirname.split(os.sep)
        aa = re.search('fly_*(\d+)', dir_parts[-3])
        flynum = int(aa.groups()[0])
    except AttributeError:
        print('Could not find the fly number from movie name')
        print('{} isnt in standard format'.format(smovies[ndx]))
        return 0
    return flynum


def _get_crop_locs(lblfile, view, crop_reg_file, crop_size):
    # everything is in matlab indexing
    print('Crop locs', view, '->',
          crop_size, 'from', lblfile, 'and', crop_reg_file)
    if tarfile.is_tarfile(lblfile):
        print('Open as tar', lblfile)
        with tarfile.open(lblfile) as tar:
            tdir = tempfile.mkdtemp()
            fname = 'label_file.lbl'
            tar.extract(fname, tdir)
            bodylbl = apt.loadmat(os.path.join(tdir, fname))
    else:
        bodylbl = apt.loadmat(lblfile)
    try:
        lsz = np.array(bodylbl['labeledpos']['size'])
        curpts = np.nan * np.ones(lsz).flatten()
        idx = np.array(bodylbl['labeledpos']['idx']) - 1
        val = np.array(bodylbl['labeledpos']['val'])
        curpts[idx] = val
        curpts = np.reshape(curpts, np.flipud(lsz))
    except IndexError:
        if bodylbl['labeledpos'].ndim == 3:
            curpts = np.array(bodylbl['labeledpos'])
            curpts = np.transpose(curpts, [2, 1, 0])
        else:
            if hasattr(bodylbl['labeledpos'][0], 'idx'):
                lsz = np.array(bodylbl['labeledpos'][0].size)
                curpts = np.nan * np.ones(lsz).flatten()
                idx = np.array(bodylbl['labeledpos'][0].idx) - 1
                val = np.array(bodylbl['labeledpos'][0].val)
                curpts[idx] = val
                curpts = np.reshape(curpts, np.flipud(lsz))
            else:
                curpts = np.array(bodylbl['labeledpos'][0])
                curpts = np.transpose(curpts, [2, 1, 0])
    neck_locs = curpts[0, :, view._neck_loc()]
    reg_params = apt.loadmat(crop_reg_file)
    x_reg = reg_params[view._coord_param('x')]
    y_reg = reg_params[view._coord_param('y')]
    x_left = int(round(x_reg[0] + x_reg[1] * neck_locs[0]))
    x_left = 1 if x_left < 1 else x_left
    x_right = x_left + crop_size[0] - 1
    y_top = int(round(y_reg[0] + y_reg[1] * neck_locs[1]))-20
    y_top = 1 if y_top < 1 else y_top
    y_bottom = y_top + crop_size[1] - 1
    return tuple([x_left, x_right, y_top, y_bottom])


def _getexpname(dirname):
    dirname = os.path.normpath(dirname)
    dir_parts = dirname.split(os.sep)
    expname = (dir_parts[-6] + "!" + dir_parts[-3] + "!" + dir_parts[-1][-10:-4]
               if len(dir_parts) > 6
               else dir_parts[-3] + "!" + dir_parts[-1][-10:-4])
    return expname


def _get_frame_dims(movie_file):
    cap = cv2.VideoCapture(movie_file)
    height = int(cap.get(cvc.FRAME_HEIGHT))
    width = int(cap.get(cvc.FRAME_WIDTH))
    cap.release()
    return height, width


def _get_movies_list(movies_filename):
    if movies_filename is not None:
        with open(movies_filename, "r") as text_file:
            text_file_lines = text_file.readlines()
        return [x.rstrip() for x in text_file_lines]
    else:
        return []


def _get_flydata(movies_list, label_filename):
    flydata = {}
    for ff in movies_list:
        if not os.path.isfile(ff):
            print("Movie %s not found" % (ff), file=sys.stderr)
            raise exit(1)
        ff_flynum = _extract_flynum_from_filename(ff)
        current_flydata = flydata.get(ff_flynum)
        if current_flydata is None:
            current_flydata = FlyData(ff_flynum)
            flydata[ff_flynum] = current_flydata
        current_flydata._add_movie(ff)

    with open(label_filename, 'r') as f:
        for l in f:
            lparts = l.split(',')
            if len(lparts) != 2:
                print("Error splitting body label file line %s into two parts" % l, file=sys.stderr)
                raise exit(1)
            current_flynum = int(lparts[0])
            current_flydata = flydata.get(current_flynum)
            if current_flydata is not None:
                current_flydata._set_label_file(lparts[1].strip())

    return flydata


def _load_model(lbl_file, view, model_type, model_dir, model_name):
    print('Load model', lbl_file, model_dir, model_name)
    tf.reset_default_graph()
    conf = apt.create_conf(lbl_file,
                           view=view,
                           name=model_name,
                           cache_dir=model_dir,
                           net_type=model_type)
    _update_conf(conf)
    for try_num in range(4):
        try:
            tf.reset_default_graph()
            pred_fn, close_fn, model_file = apt.get_pred_fn(model_type=model_type,
                                                            conf=conf)
            break
        except ValueError:
            print('Loading the net failed, retrying')
            if try_num is 3:
                raise ValueError('Couldnt load the network after 4 tries')

    return conf, model_file, pred_fn


def _process_movie(movie_filename, view, flydata, crop_size,
                   conf, model_type, model_file, pred_fn,
                   outdir,
                   force=True):
    mname, _ = os.path.splitext(os.path.basename(movie_filename))
    oname = re.sub('!', '__', _getexpname(movie_filename))
    pname = os.path.join(outdir, oname + '_' + view._name())
    resname = pname + '.mat'
    print('pname=', pname, 'oname=', oname)
    if os.path.isfile(resname) and not force:
        # result already exist and we do not force re-process
        print("Result file", resname, "already exist")
        return resname

    print('Detecting:%s' % oname)
    height, width = _get_frame_dims(movie_filename)

    crop_loc_all = _adjust_crop_region(flydata._crop_locs,
                                       crop_size,
                                       height, width)
    try:
        predLocs, predScores, pred_ulocs, pred_conf = _classify_movie(
            movie_filename, pred_fn, conf,
            crop_loc_all, model_type)
    except KeyError:
        print('Error classifying', movie_filename)
        return None
    hdf5storage.savemat(resname, {'locs': predLocs,
                                  'scores': predScores,
                                  'expname': movie_filename,
                                  'crop_loc': crop_loc_all,
                                  'model_file': model_file,
                                  'ulocs': pred_ulocs,
                                  'pred_conf': pred_conf
                                  },
                        appendmat=False,
                        truncate_existing=True,
                        gzip_compression_level=0)
    del predScores, predLocs
    return resname


def _size_arg(arg):
    if arg:
        arg_parts = arg.split(',')
        int_parts = [int(i) for i in arg_parts[0:2]]
        if len(int_parts) < 2:
            raise ValueError("Size expected to have 2 components: sx,sy")
        return int_parts
    else:
        return None


def _update_conf(conf):
    conf.normalize_img_mean = False
    conf.adjust_contrast = True
    conf.dl_steps = 60000


def main(argv):
    parser = argparse.ArgumentParser()
    parser.add_argument("-movies", dest="movies",
                        nargs="+",
                        help="List of movies to classify.")
    parser.add_argument("-movie_list_filename", dest="movies_file",
                        help="File containing the list of movies to classify.")
    parser.add_argument("-view", dest="view",
                        type=_View._argtype, choices=list(_View),
                        help="View type for all movies.",
                        required=True)
    parser.add_argument("-r", dest="redo",
                        help="if specified will recompute everything even if previous results exists",
                        default=False,
                        action="store_true")
    parser.add_argument("-bodylabelfilename",
                        dest="body_lbl_assoc_file",
                        help="text file with list of body-label lookup files, one per fly as 'flynum,/path/to/body_label.lbl'")
    parser.add_argument("-lbl_file",
                        dest="lbl_file",
                        help="Label file name")
    parser.add_argument("-model_type", dest="model_type",
                        help="Model type: {mdm|unet}",
                        default="mdn")
    parser.add_argument("-crop_reg_file", dest="crop_reg_file",
                        help="Regression file",
                        required=True)
    parser.add_argument("-view_crop_size",
                        dest="view_crop_size",
                        metavar="dx,dy",
                        type=_size_arg,
                        help='View crop size')
    parser.add_argument("-cache_dir",
                        dest="model_cache_dir")
    parser.add_argument("-n", dest="model_name",
                        help="model name",
                        default="latest")
    parser.add_argument("-o", dest="outdir",
                        help="temporary output directory to store intermediate computations",
                        required=True)

    args = parser.parse_args(argv)

    outdir = os.path.abspath(args.outdir)
    os.makedirs(outdir, exist_ok=True)

    view_crop_size = (args.view_crop_size
                      if args.view_crop_size is not None
                      else args.view._default_crop_size())

    movies = args.movies + _get_movies_list(args.movies_file)

    flydata = _get_flydata(movies,
                           args.body_lbl_assoc_file)

    conf, model_file, pred_fn = _load_model(args.lbl_file, args.view.value,
                                            args.model_type, args.model_cache_dir, args.model_name)

    for flynum in flydata:
        current_flydata = flydata[flynum]
        crop_locs = _get_crop_locs(current_flydata._label_filename,
                                   args.view,
                                   args.crop_reg_file,
                                   view_crop_size)
        current_flydata._set_crop_locs(crop_locs)
        for movie_fn in current_flydata._movies_list:
            print('Process', movie_fn)
            _process_movie(movie_fn, args.view, current_flydata,
                           view_crop_size, conf,
                           args.model_type, model_file, pred_fn,
                           outdir,
                           force=args.redo)


if __name__ == "__main__":
    main(sys.argv[1:])
