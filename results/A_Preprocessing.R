# Data processing for experiments on regularity extraction in noise in baboons (2-item in 4-item sequence)
# (C) Jeremy D Yeaton
# September 2020

# Import and Preprocessing ------------------------------------------------
library(tidyverse)
'%notin%' <- function(x,y)!('%in%'(x,y))

# Specify minimum and maximum allowable RTs
rtMin = 0
rtMax = 800

# Experiment 1 ------------------------------------------------------------

# Read in raw data
raw_exp1 <- read_delim('results/data/results_raw_exp1.txt', delim='\t',col_types=cols()) %>%
  # Get rid of unnecessary columns
  select(-c(Programme,Manip,Famille,reward,Test,target6,target7,target8,
            target9,target10,target11,target12,rt5,rt6,rt7,rt8,rt9,rt10,rt11,
            rt12,rt13,rt14,rt15,rt16,touch1,touch2,touch3,touch4,RT,
            NbBloc,list1Criteria)) %>%
  # More transparent column names
  rename(name = Nom, rawBlock = nObjAtteint, trialInBlock = nessai)

# Get number of completed trials by baboon
trialCounts <- raw_exp1 %>%
  group_by(name) %>%
  summarise(nTrials = n(),.groups='keep')

# Read in meta and group information (mostly about blocks and block orders)
brut_exp1 <- read.table('results/data/metaInfo_exp1.txt',sep = '\t', header = TRUE) %>%
  merge(read_csv('results/data/groupInfo.csv',col_types = cols()), by = 'group') %>%
  # Select useful columns
  select(c('Nom','group','pos1','pos2','pos3','blockType','blockOrder','nObjAtteint','typeOrder')) %>%
  # More transparent names
  rename(name = Nom,rawBlock = nObjAtteint) %>%
  # Add in raw data
  merge(raw_exp1,by=c('name','rawBlock')) %>%
  # More useful trial number information intead of by-block 1 to 100
  mutate(trialNum = (100*typeOrder + trialInBlock - 1)) %>%
  merge(trialCounts) %>%
  # Remove individuals who didn't finish the experiment, and trials that weren't completed
  filter(nTrials == 2000, Score == 1) %>%
  # Get/assign information about targets within trial
  mutate(ptPair1 = paste('#',target1,sep = ''),
         ptPair2 = paste(target1,target2,sep=''),
         ptPair3 = paste(target2,target3,sep=''),
         ptPair4 = paste(target3,target4,sep=''),
         targetPair = case_when(blockType == 'pos1' ~ paste(target1,target2,sep=''),
                                blockType == 'pos2' ~ paste(target2,target3,sep=''),
                                blockType == 'pos3' ~ paste(target3,target4,sep=''),
                                blockType == 'rnd' ~ paste(0,0,sep=''))) %>%
  # Reshape long so each touch is on its own line
  pivot_longer(cols = starts_with('rt'),names_to = 'rtType', values_to = 'rtVal') %>%
  mutate(ptPair = case_when(rtType == 'rt1' ~ ptPair1,
                            rtType == 'rt2' ~ ptPair2,
                            rtType == 'rt3' ~ ptPair3,
                            rtType == 'rt4' ~ ptPair4),
         # Specify pair types:
         # XX = random block, 
         # A = 1st in AB regularity, 
         # B = 2nd in AB regularity
         # XY = in an experimental (non-random) trial, but not in the AB regularity
         pairType = case_when(blockType == 'rnd' ~ 'XX',
                              ptPair == targetPair ~ 'B',
                              substr(ptPair,2,2) == substr(targetPair,1,1) ~ 'A',
                              TRUE ~ 'XY')) %>%
  # Remove unnecessary columns
  select(-c(Score,bonnesrep,target1,target2,target3,target4,
            target5,pos1,pos2,pos3,ptPair1,ptPair2,ptPair3,
            ptPair4,group,blockOrder,typeOrder,nTrials))



# Clean up the data by removing outliers
exp1 <- brut_exp1 %>%
  # Filter out RTs outside of allowable range
  filter(rtVal <= rtMax & rtVal >= rtMin) %>%
  group_by(name,rawBlock) %>%
  summarize(meanRT = mean(rtVal),
            sdRT = sd(rtVal),.groups='keep') %>%
  merge(brut_exp1) %>%
  mutate(rtZ = (rtVal-meanRT)/sdRT) %>%
  # Filter out RTs greater than 2.5 SD from each baboon's mean
  filter(abs(rtZ) <= 2.5) %>%
  # More transparent column name
  rename(cond = blockType) %>%
  # Make columns for when combined with experiment 2
  mutate(condition = ifelse(cond == 'rnd','rnd4','fix4'),
         expNum = 1) %>%
  # Make timestamps more friendly
  separate(Date,into = c('day','month','year'),sep='/') %>%
  separate(Heure,into=c('hour','minute','second'),sep=':') %>%
  # Drop unnecessary columns
  select(-c(meanRT,sdRT,rtZ))

# Calculate percent data loss
exp1.loss <- (nrow(brut_exp1)-nrow(exp1))/nrow(brut_exp1)
print(paste('Exp 1:',exp1.loss))

# Random sequencing times -------------------------------------------------

# Read in times from previous 6-touch experiment
old_rnd_times <- read_csv('results/data/transitionTimes.csv',col_types = cols()) %>%
  rename(start = Pos1,
         stop = Pos2,
         oldTime = time) %>%
  mutate(ptPair = paste(start,stop,sep=''))

# Get transition times from random block of exp 1
rndTimes <- exp1 %>%
  filter(cond == 'rnd') %>%
  group_by(ptPair) %>%
  summarize(baseRt = mean(rtVal),
            nTrials = n(),.groups='keep') %>%
  merge(old_rnd_times,by= 'ptPair',all = TRUE) %>%
  mutate(start = substr(ptPair,1,1),
         stop = substr(ptPair,2,2))

# Experiment 2 ------------------------------------------------------------

# Read in raw data from site
raw_exp2 <- read_delim('results/data/results_raw_exp2.txt',delim='\t',col_types = cols()) %>%
  # Drop unnecessary columns
  select(Nom,Date,Heure,Box,Sexe,nObjAtteint,Age,nessai,Mois,HH,Score,longsequence,
         target1,target2,target3,target4,target5,rt1,rt2,rt3,rt4,rt5) %>%
  # More transparent column names
  rename(name = Nom,rawBlock = nObjAtteint,trialInBlock = nessai)

brut_exp2 <- raw_exp2 %>%
  group_by(name) %>%
  # Get number of completed trials by baboon
  summarize(numFinished = n(),.groups='keep') %>%
  merge(raw_exp2)%>%
  # Read in target pairs for experimental trials
  merge(read_csv('results/data/targetpairs_exp2.csv',col_types = cols())) %>%
  # Identify experimental vs warm-up trials
  mutate(cond = ifelse(rawBlock %in% c(0,1,7,8),'rnd','var')) %>%
  # Clean up block identifiers
  mutate(blockType = paste(cond,longsequence,sep=''),
         blockNum = ifelse(cond == 'rnd',
                           ifelse(rawBlock > 2,rawBlock - 7, rawBlock),
                           ifelse(rawBlock < 7,rawBlock - 2, rawBlock - 9))) %>%
  mutate(blockNum = blockNum + 1) %>%
  # More useful trial number information intead of by-block 1 to 100
  mutate(trialNum = (blockNum-1)*100 + trialInBlock,
         # ID trials as being from experiment 2
         expNum = 2) %>%
  # Drop baboons who didn't finish the task and trials that weren't completed
  filter(numFinished > 1390 & Score == 1) %>%
  # Get start and end points for each touch
  mutate(ptPair1 = paste('#',target1,sep = ''),
         ptPair2 = paste(target1,target2,sep=''),
         ptPair3 = paste(target2,target3,sep=''),
         ptPair4 = paste(target3,target4,sep=''),
         ptPair5 = paste(target4,target5,sep='')) %>%
  # Pivot longer so one touch per row
  pivot_longer(cols = starts_with('rt'),names_to = 'rtType', values_to = 'rtVal') %>%
  # Assign start and end points for each touch
  mutate(ptPair = case_when(rtType == 'rt1' ~ ptPair1,
                            rtType == 'rt2' ~ ptPair2,
                            rtType == 'rt3' ~ ptPair3,
                            rtType == 'rt4' ~ ptPair4,
                            rtType == 'rt5' ~ ptPair5),
         # Specify pair types:
         # XX = random block, 
         # A = 1st in AB regularity, 
         # B = 2nd in AB regularity
         # XY = in an experimental (non-random) trial, but not in the AB regularity
         pairType = case_when(cond == 'rnd' ~ 'XX',
                              ptPair == targetPair ~ 'B',
                              substr(ptPair,2,2) == substr(targetPair,1,1) ~ 'A',
                              TRUE ~ 'XY')) %>%
  # Drop unnecessary columns
  select(-c(target1,target2,target3,target4,target5,ptPair1,ptPair2,
            ptPair3,ptPair4,ptPair5,numFinished,Score))

# Clean up data by removing outliers
exp2 <- brut_exp2 %>%
  # Filter RTs outside of allowable range
  filter(rtVal <= rtMax & rtVal >= rtMin) %>%
  group_by(name,rawBlock) %>%
  summarize(mm = mean(rtVal), 
            stdev = sd(rtVal),.groups='keep') %>%
  merge(brut_exp2) %>%
  mutate(Z = (rtVal - mm)/stdev) %>%
  # Filter RT's greater than 2.5 SD from each baboon's mean
  filter(abs(Z) <= 2.5) %>%
  # Assign condition IDs
  mutate(condition = case_when(blockType == 'rnd4' ~ 'rndExp2',
                               blockType == 'rnd5' ~ 'rndExp2',
                               TRUE ~ blockType)) %>%
  # Make timestamps more friendly
  separate(Date,into = c('day','month','year'),sep='/') %>%
  separate(Heure,into=c('hour','minute','second'),sep=':') %>%
  # Drop unnecessary columns
  select(-c(Z,stdev,mm,blockNum,blockType))

# Calculate percent data loss
exp2.loss <- (nrow(brut_exp2)-nrow(exp2))/nrow(brut_exp2)
print(paste('Exp 2:',exp2.loss))

# Combine data from both experiments --------------------------------------

bothExp <- rbind(exp1,exp2) %>%
  select(name) %>%
  distinct() %>%
  # Assign numberic IDs to baboons
  mutate(babNum = 1:24) %>%
  mutate(babNum = as.factor(babNum)) %>%
  merge(rbind(exp1,exp2))

# Write data to file
write_csv(bothExp,'results/data/both_experiments.csv')
write_csv(rndTimes,'results/data/rndTimes.csv')

bothExp %>%
  select(babNum,name) %>%
  mutate(babNum = as.numeric(babNum)) %>%
  # filter(babNum < 21) %>%
  distinct() %>%
  write_csv(.,'results/data/babIDs.csv')

# Clean up workspace
rm(old_rnd_times,brut_exp1,brut_exp2,exp1,exp2,raw_exp1,raw_exp2,trialCounts)


