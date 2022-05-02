# Results & analysis

This directory contains the analysis code for the reported results. All of the data are available on the [OSF repository](https://osf.io/q9z2m/).

## Scripts

This directory contains all of the preprocessing and analysis code. The contents of each file and the data that they rely on are laid out below.

### Dependencies
This pipeline relies on the following R packages:
  
- [tidyverse](https://www.tidyverse.org/)

- [BayesFactor](https://cran.r-project.org/web/packages/BayesFactor/index.html)

- [pracma](https://cran.r-project.org/web/packages/pracma/index.html)

- [tie](https://rdrr.io/github/romainfrancois/tie/)

- [ggpubr](https://cran.r-project.org/web/packages/ggpubr/index.html)

- [viridis](https://cran.r-project.org/web/packages/viridis/index.html)

- [broom](https://cran.r-project.org/web/packages/broom/index.html)

- [lme4](https://cran.r-project.org/web/packages/lme4/index.html)

- [lmerTest](https://cran.r-project.org/web/packages/lmerTest/index.html)


### File list

- **A_Preprocessing.R**: Reads in *results_raw_exp1.txt*, *metaInfo_exp1.txt*, *groupInfo.csv*, *transitionTimes.csv*, *results_raw_exp2.txt*, *targetpairs_exp2.csv* (the contents of each of these is given in more detail below). It then applies the preprocessing steps outlined in the paper for cleaning the data, and joins the data from the two experiments into *both_experiments.csv*, as well as returning *rndTimes.csv* and *babIDs.csv*. _**If you do not wish to change the preprocessing parameters, you do not need to run this script.**_

- **B_Bayesian_Analyses.R**: This file contains the bulk of the analysis. It reads in *both_experiments.csv*, calculates the slope of the RTs for each baboon and condition, runs the omnibus Bayesian RM-ANOVAs and post-hoc pairwise tests, and simulates the posterior distributions for each condition.

- **C_Figures_LandB.R**: This produces the figures presented in the paper.

- **appendixes.Rmd**: This is the R Markdown file which produces the tables and results shown in the appendixes of the paper. It requires *rndTimes.csv*, *metaInfo_exp1.txt*, *babIDs.csv*, *targetpairs_exp2.csv*, *babs_by_exp.csv*, and *X1_LMER_models.RData*.

- **X1_LMER.R**: This file deads in **both_experiments.csv* and runs the LMER analyses presented in Appendix D of the paper. If you do not wish to change the models, the converged models are saved in the *X1_LMER_models.RData* R environment file contained in this repository.

## Data
This directory contains the files listed below. 

- **babIDs.csv**: Contains the baboon names and the numbers used to identify them in the analyses.

- **babs_by_exp.csv**: This lists out the participating baboons and which conditions they completed.

- **both_experiments.csv**: Preprocessed RTs from both experiments. Additional information is provided about the columns in this file below.

- **groupInfo.csv**: Contains the condition assignments for the block numbers across the different assigned groups for Experiment 1.

- **metaInfo_exp1.txt**: Contains the assigned AB pairs and condition orders for each baboon for Experiment 1.

- **results_raw_exp1.txt**: Raw RT data from Experiment 1.

- **results_raw_exp2.txt**: Raw RT data from Experiment 2.

- **rndTimes.csv**: Contains the transition times under random sequencing conditions for each possible AB pair. This holds the RTs from a previous experiment (_oldTime_ column; redundant with *transitionTimes.csv* below), as well as the RTs from the blocks of 500 randomly-sequenced trials from Experiment 1 (_baseRt_ column), as well as how many trials those averages are based on (_nTrials_ column). 

- **targetpairs_exp2.csv**: Contains the AB target pairs for each baboon for each condition in Experiment 2.

- **transitionTimes.csv**: Transition RTs for each possible AB point pair collected from a previous experiment.

- **X1_LMER_models.RData**: This is an R environment file that contains the converged LMER models presented in Appendix D.

I recognize that these descriptions are mostly not very informative but most of these files you probably won't need. Happy to provide more detail if you'd like (jyeaton@uci.edu).

### both_experiments.csv
This is the main data file you might want to use. Each row represents a single touch within a trial (and therefore a single RT). The columns are below:
  
  - *name*: Baboon name

- *babNum*: Baboon ID number (1-24)

- *rawBlock*: Order block was presented in the experiment (0-19 and 0-13 for Exp 1 and 2 respectively).

- *cond*: Condition for Experiment 1: rnd (random sequencing), pos1, pos2, pos3 (ABXX, XABX, and XXAB respectively). Var for Exp 2.

- *day*: Day of month trial completed

- *month*: Month trial completed

- *year*: Year trial completed

- *hour*: Hour trial completed

- *minute*: Minute trial completed

- *second*: Second trial completed

- *Box*: Experimental station used for that trial

- *Sexe*: Baboon's sex

- *Age*: Baboon's age (in months)

- *trialInBlock*: Position of trial within block of 100

- *Mois*: Month (but in French)

- *HH*: I think this is Hour but I'm honestly not sure...

- *longsequence*: Trial length -- either 4 or 5 depending on condition

- *trialNum*: Trial number within condition for that baboon. 0-499 for all conditions except reacclimation blocks of Exp 2 which were 0-199.

- *targetPair*: AB pair for a given trial. 00 if in the random condition.

- *rtType*: Position in trial of touch. rt1 = first touch of the trial, rt2 = second touch, etc.

- *rtVal*: Response Time in milliseconds (ms)

- *ptPair*: Start and stop points for that touch, i.e.: the target for touch n-1 and the target for the current touch.

- *pairType*: Type of transition. XX = any transition in a random trial, XY = transition between two random points in a trial with a regularity, A = transition to the A element of an AB pair, B = transition from A to B in an AB regularity. This is the primary pair type of interest for our analyses.

- *condition*: Condition for Exp 2/ combined analysis. fix4 = combined data from ABXX, XABX, and XXAB conditions, var4 = variable position of AB regularity within a 4-element trial, var5 = variable position of AB regularity within a 5-element trial

- *expNum*: Experiment number -- 1 or 2


