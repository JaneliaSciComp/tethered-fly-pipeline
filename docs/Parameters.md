# Tethered fly pipeline parameters

This pipeline uses Nextflow and processes videos of tethered flies using APT to produce tracking output.

## Data

Filepaths to directories and files used for input and output

| Parameter | Description | Type |
|-----------|-----------|-----------|
| `input_dir` | Top level directory for experiment containing all individual fly subdirectories | `string` |
| `output_dir` | Directory where final results `.trk`, `_3dres.mat` will be generated. The per fly and per video results will be generated in the corresponding subfolders as found in the input, e.g., `.../fly4315/C001H001S0002/C001H001S0002_c.trk` | `string` |
| `tmp_tracking_dir` | Directory containing the intermediate results generated during the `detect` step | `string` |
| `scratch_dir` | Temp scratch directory for holding results before moving them to final destination | `string` |
| `label_filename` | e.g. `/groups/branson/bransonlab/apt/experiments/data/sh_trn5017_20200121_stripped.lbl` | `string` |
| `body_axis_lookup_filename` | .csv file containing fly numbers with the corresponding body axis .lbl files e.g. `/groups/huston/hustonlab/flp-chrimson_experiments/fly2BodyAxis_lookupTable_Ben.csv` | `string` |
| `crop_regression_filename` | e.g. `/groups/branson/bransonlab/mayank/stephen_copy/crop_regression_params.mat` | `string` |
| `model_name` | e.g. `stephen_20200124` | `string` |
| `calibrations_filename` | .csv file containing fly numbers with the corresponding calibration files | `string` |
| `model_cache_dirname` | `/groups/branson/bransonlab/mayank/stephen_copy/apt_cache` | `string` |
| `flydata_dirname_pattern` | Regex pattern for selecting the fly directories. This can be used for running the pipeline only for one or two flies for example: `fly123[4,8]` - selects only `fly1234` and `fly1238` as inputs. Default: `fly[0-9]*` | `string` |
| `flydata_maxdepth_search` | If greater than 0 it specifies how many levels to look for flydata directories under input_dir. Default: `0` (unlimitted) | `integer` |
| `sideview_videoname_pattern` | Filename pattern for **SIDE** view videos. Changing this may require settting `frontview_videoname_pattern` so that we process the side and front view in pairs. Default: `C001*.avi` | `string` |
| `frontview_videoname_pattern` | Filename pattern for **FRONT** view videos. Changing this may require settting `sideview_videoname_pattern` so that we process the side and front view in pairs.  Default: `C002*.avi` | `string` |
| `sideview_detect_result_suffix` | Filename suffix used for **SIDE** view intermediated results. Default: `_side` | `string` |
| `frontview_detect_result_suffix` | Filename suffix used for **FRONT** view intermediate results. Default: `_front` | `string` |

## Detection parameters

Parameters for the detection step

| Parameter | Description | Type |
|-----------|-----------|-----------|
| `sideview_crop_size` | Default crop size used for **SIDE** view. Only change this if you know how this impacts the algorithm. Default: `230,350` | `string` |
| `frontview_crop_size` | Default crop size used for **FRONT** view. Only change this if you know how this impacts the algorithm. Default: `350,350` | `string` |
| `apt_detect_cpus` | Number of CPU cores for detection. Default: 2 | `string` |
| `apt_detect_memory` | Amount of memory for detection. Default: 30 G | `string` |

## Tracking parameters

Parameters for the tracking step

| Parameter | Description | Type |
|-----------|-----------|-----------|
| `apt_track_cpus` | Number of CPU cores for tracking. Default: 3 | `string` |
| `apt_track_memory` | Amount of memory for tracking. Default: 45 G | `string` |

## Container Options

Customize the Docker containers used for each pipeline step

| Parameter | Description | Type |
|-----------|-----------|-----------|
| `apt_detect_container` | Docker container for running detect using APT. Default: `registry.int.janelia.org/huston/apt_detect:1.0` | `string` |
| `apt_track_container` | Docker container for running tracking using APT. Default: `registry.int.janelia.org/huston/apt_track:1.0` | `string` |

## Other Options

Other global options affecting all pipelines stages

| Parameter | Description | Type |
|-----------|-----------|-----------|
| `singularity_cache_dir` | Shared directory where Singularity containers are cached. Default: $shared_work_dir/singularity_cache or $HOME/.singularity_cache | `string` |
| `singularity_user` | User to use for running Singularity containers. Default: $USER <details><summary>Help</summary><small>This is automatically set to `ec2-user` when using the 'tower' profile</small></details>| `string` |
| `runtime_opts` | Runtime options for the container engine being used (e.g. Singularity or Docker). <details><summary>Help</summary><small>Runtime options for Singularity must include mounts for any directory paths you are using. You can also pass the --nv flag here to make use of NVIDIA GPU resources. For example, `--nv -B /your/data/dir -B /your/output/dir`
</small></details>| `string` |
| `lsf_opts` | Options for LSF cluster at Janelia, when using the lsf profile. | `string` |
