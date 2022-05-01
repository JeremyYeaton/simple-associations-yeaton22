# README
This folder contains the scripts and data that were used to produce the stimuli used in the two experiments. The files are outlined below.

## Files list
### Experiment 1
- **create_input_exp1.py**: Script to produce the stimuli. It is written in blocks for use in Spyder. These blocks are divided into two main parts: 1) select pairs groups of 3 point pairs for each baboon with comparable baseline RTs to be employed as the AB stimuli in the experiment, and 2) produce the stimuli files with the regularities in the designated positions and fill in the random noise points. 
- **pairDict_max5.pkl**: This file contains the AB pairs produced by part 1 above, so unless you want to change the parameters, this can be reused.
- **transitionTimes.csv**: This file contains the baseline RTs from a previous experiment which were used for part 1 above.

### Experiment 2
- **create_input_expt2.py**: Same as above, except for only two conditions for each baboon instead of three and using the RTs from the random block of Exp 1 instead of from a previous experiment.
- **pairDict_exp2_max3.pkl**: This file contains the AB pairs produced by the first part of the above file.
- **rndTimes.csv**: This file contains the average transition times from the random block of Exp 1.

Any questions can be directed to the first author at jyeaton@uci.edu
