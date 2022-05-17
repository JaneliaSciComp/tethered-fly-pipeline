#!/usr/bin/env python

import argparse
import ast
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


def size_list_arg(arg):
    return list(ast.literal_eval(arg))


def classify_movie(mov_file, pred_fn, conf, crop_loc, model_type):
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

    cap.close()
    return pred_locs, preds, pred_ulocs, uconf


def get_crop_locs(lblfile, view, crop_reg_file, crop_size, height, width):
    # everything is in matlab indexing
    print('Crop locs from', lblfile)
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
    neck_locs = curpts[0, :, 5 + 10 * view]
    reg_params = apt.loadmat(crop_reg_file)
    x_reg = reg_params['reg_view{}_x'.format(view + 1)]
    y_reg = reg_params['reg_view{}_y'.format(view + 1)]
    x_left = int(round(x_reg[0] + x_reg[1] * neck_locs[0]))
    x_left = 1 if x_left < 1 else x_left
    x_right = x_left + crop_size[view][0] - 1
    if x_right > width:
        x_left = width - crop_size[view][0] + 1
        x_right = width
    y_top = int(round(y_reg[0] + y_reg[1] * neck_locs[1]))-20
    y_top = 1 if y_top < 1 else y_top
    y_bottom = y_top + crop_size[view][1] - 1
    if y_bottom > height:
        y_bottom = height
        y_top = height - crop_size[view][1] + 1
    return [x_left, x_right, y_top, y_bottom]


def getexpname(dirname):
    dirname = os.path.normpath(dirname)
    dir_parts = dirname.split(os.sep)
    expname = dir_parts[-6] + "!" + dir_parts[-3] + "!" + dir_parts[-1][-10:-4]
    return expname


def get_movies_and_body_labels(smovies_filename, fmovies_filename, label_filename):

    with open(smovies_filename, "r") as text_file:
        smovies = text_file.readlines()
    smovies = [x.rstrip() for x in smovies]

    with open(fmovies_filename, "r") as text_file:
        fmovies = text_file.readlines()
    fmovies = [x.rstrip() for x in fmovies]

    print(smovies)
    print(fmovies)
    print(len(smovies))
    print(len(fmovies))

    if len(smovies) != len(fmovies):
        print("Side and front movies must match")
        raise exit(0)

    for ff in smovies+fmovies:
        if not os.path.isfile(ff):
            print("Movie %s not found" % (ff))
            raise exit(0)

    bodydict = {}
    with open(label_filename, 'r') as f:
        for l in f:
            lparts = l.split(',')
            if len(lparts) != 2:
                print("Error splitting body label file line %s into two parts" % l)
                raise exit(0)
            bodydict[int(lparts[0])] = lparts[1].strip()

    return smovies, fmovies, bodydict


def update_conf(conf):
    conf.normalize_img_mean = False
    conf.adjust_contrast = True
    conf.dl_steps = 60000


def main(argv):
    parser = argparse.ArgumentParser()
    parser.add_argument("-s", dest="sfilename",
                        help="text file with list of side view videos",
                        required=True)
    parser.add_argument("-f", dest="ffilename",
                        help="text file with list of front view videos. The list of side view videos and front view videos should match up",
                        required=True)
    parser.add_argument("-r", dest="redo",
                        help="if specified will recompute everything",
                        default=False,
                        action="store_true")
    parser.add_argument("-bodylabelfilename",
                        dest="body_lbl_assoc_file",
                        help="text file with list of body-label files, one per fly as 'flynum,/path/to/body_label.lbl'")
    parser.add_argument("-lbl_file",
                        dest="lbl_file",
                        help="text file with list of body-label files, one per fly as 'flynum,/path/to/body_label.lbl'")
    parser.add_argument("-o", dest="outdir",
                        help="temporary output directory to store intermediate computations",
                        required=True)
    parser.add_argument("-model_type", dest="model_type",
                        help="Model type: {mdm|unet}",
                        default="mdn")
    parser.add_argument("-crop_reg_file", dest="crop_reg_file",
                        help="Regression file",
                        required=True)
    parser.add_argument('-crop_size',
                        dest='crop_size',
                        metavar='(dx0,dy0),(dx1,dy1)',
                        type=size_list_arg,
                        default='[230,350],[350,350]',
                        help='Crop sizes')
    parser.add_argument("-cache_dir", dest="cache_dir")
    parser.add_argument("-n", dest="name",
                        help="output name",
                        default="latest")
    parser.add_argument("-gpu", dest='gpunum', type=int,
                        help="GPU to use [optional]")

    args = parser.parse_args(argv)

    args.outdir = os.path.abspath(args.outdir)

    smovies, fmovies, bodydict = get_movies_and_body_labels(args.sfilename,
                                                            args.ffilename,
                                                            args.body_lbl_assoc_file)

    for view in range(2):  # 0 for side and 1 for front
        tf.reset_default_graph()
        conf = apt.create_conf(args.lbl_file,
                               view=view,
                               name=args.name,
                               cache_dir=args.cache_dir,
                               net_type=args.model_type)
        update_conf(conf)
        if view == 0:
            # from stephenHeadConfig import sideconf as conf
            extrastr = '_side'
            valmovies = smovies
        else:
            # For FRONT
            # from stephenHeadConfig import conf as conf
            extrastr = '_front'
            valmovies = fmovies

        for try_num in range(4):
            try:
                tf.reset_default_graph()
                pred_fn, close_fn, model_file = apt.get_pred_fn(model_type=args.model_type,
                                                                conf=conf)
                break
            except ValueError:
                print('Loading the net failed, retrying')
                if try_num is 3:
                    raise ValueError(
                        'Couldnt load the network after 4 tries')

        for ndx in range(len(valmovies)):
            mname, _ = os.path.splitext(os.path.basename(valmovies[ndx]))
            oname = re.sub('!', '__', getexpname(valmovies[ndx]))
            pname = os.path.join(args.outdir, oname + extrastr)

            print(oname)

            # detect
            if (args.redo or not os.path.isfile(pname + '.mat')):

                cap = cv2.VideoCapture(valmovies[ndx])
                height = int(cap.get(cvc.FRAME_HEIGHT))
                width = int(cap.get(cvc.FRAME_WIDTH))
                cap.release()
                try:
                    dirname = os.path.normpath(valmovies[ndx])
                    dir_parts = dirname.split(os.sep)
                    aa = re.search('fly_*(\d+)', dir_parts[-3])
                    flynum = int(aa.groups()[0])
                except AttributeError:
                    print('Could not find the fly number from movie name')
                    print('{} isnt in standard format'.format(smovies[ndx]))
                    continue
                crop_loc_all = get_crop_locs(bodydict[flynum], view,
                                             args.crop_reg_file,
                                             args.crop_size,
                                             height, width)  # return x first
                try:
                    predLocs, predScores, pred_ulocs, pred_conf = classify_movie(
                        valmovies[ndx], pred_fn, conf, crop_loc_all, args.model_type)
                except KeyError:
                    continue

                hdf5storage.savemat(pname + '.mat', {'locs': predLocs,
                                                     'scores': predScores,
                                                     'expname': valmovies[ndx],
                                                     'crop_loc': crop_loc_all,
                                                     'model_file': model_file,
                                                     'ulocs': pred_ulocs,
                                                     'pred_conf': pred_conf
                                                     },
                                    appendmat=False, truncate_existing=True, gzip_compression_level=0)
                del predScores, predLocs

                print('Detecting:%s' % oname)


if __name__ == "__main__":
    main(sys.argv[1:])
