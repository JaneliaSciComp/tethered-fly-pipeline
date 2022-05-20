# Parameters

The pipeline supports many types of parameters for customization to your compute environment and data. These can all be specified on the command line using the standard syntax `--argument="value"` or `--argument "value"`. You can also use any option supported by Nextflow itself. Note that certain arguments (i.e. those interpreted by Nextflow) use a single dash instead of two.


## Data Input/Output Arguments

| Argument   |Description                                                                           |
|------------|---------------------------------------------------------------------------------------|
| --i| Top level directory for experiment containing all individual fly subdirectories |
| --o | Directory where final results `.trk`, `_3dres.mat` will be generated |
| --tmp_tracking_dir | Directory containing the intermediate results generated during the `detect` step |
| --body_axis_lookup_filename | /groups/huston/hustonlab/flp-chrimson_experiments/fly2BodyAxis_lookupTable_Ben.csv |
| --label_filename | /groups/branson/bransonlab/apt/experiments/data/sh_trn5017_20200121_stripped.lbl |
| --crop_regression_filename | /groups/branson/bransonlab/mayank/stephen_copy/crop_regression_params.mat |
| --model_cache_dirname | /groups/branson/bransonlab/mayank/stephen_copy/apt_cache |
| --model_name | stephen_20200124 |
| --calibrations_filename| CSV file containing fly number with the corresponding calibration file|
