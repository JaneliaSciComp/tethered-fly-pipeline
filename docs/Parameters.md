# Parameters

The pipeline supports many types of parameters for customization to your compute environment and data. These can all be specified on the command line using the standard syntax `--argument="value"` or `--argument "value"`. You can also use any option supported by Nextflow itself. Note that certain arguments (i.e. those interpreted by Nextflow) use a single dash instead of two.


## Data Input/Output Arguments

| Argument   |Description |
|-|-|
| --i| Top level directory for experiment containing all individual fly subdirectories |
| --o | Directory where final results `.trk`, `_3dres.mat` will be generated. The per fly and per video results will be generated in the corresponding subfolders as found in the input, e.g., `.../fly4315/C001H001S0002/C001H001S0002_c.trk` |
| --tmp_tracking_dir | Directory containing the intermediate results generated during the `detect` step |
| --body_axis_lookup_filename | .csv file containting fly numbers with the corresponding body axis .lbl files e.g. `/groups/huston/hustonlab/flp-chrimson_experiments/fly2BodyAxis_lookupTable_Ben.csv` |
| --label_filename | `/groups/branson/bransonlab/apt/experiments/data/sh_trn5017_20200121_stripped.lbl` |
| --crop_regression_filename | `/groups/branson/bransonlab/mayank/stephen_copy/crop_regression_params.mat` |
| --model_cache_dirname | `/groups/branson/bransonlab/mayank/stephen_copy/apt_cache` |
| --model_name | `stephen_20200124` |
| --calibrations_filename| .csv file containing fly numbers with the corresponding calibration files |


## Parameters with default values

The following parameters should almost never be touched and if you change them make sure you know what you are doing because some, such as crop_size parameters may result in failure.

| Argument | Default | Description |
|-|-|-|
| --flydata_dirname_pattern | `fly[0-9]*` | Regex pattern for selecting the fly directories. This can be used for running the pipeline only for one or two flies for example: `fly123[4,8]` - selects only `fly1234` and `fly1238` as inputs |
| --sideview_videoname_pattern | `C001*.avi` | Filename pattern for **SIDE** view videos. Changing this may require settting `frontview_videoname_pattern` so that we process the side and front view in pairs. |
| --frontview_videoname_pattern | `C002*.avi` | Filename pattern for **FRONT** view videos. Changing this may require settting `sideview_videoname_pattern` so that we process the side and front view in pairs. |
| --sideview_crop_size | `230,350` | Default crop size used for **SIDE** view. **Only change this if you know how this impacts the algorithm.** |
| --frontview_crop_size | `350,350` | Default crop size used for **FRONT** view. **Only change this if you know how this impacts the algorithm.** |
| --sideview_detect_result_suffix | `_side` | Filename suffix used for **SIDE** view intermediated results |
| --frontview_detect_result_suffix | `_front` | Filename suffix used for **FRONT** view intermediate results |
