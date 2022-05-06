# Bayesian statistics for experiments on regularity extraction in noise in baboons
# (C) Jeremy D Yeaton
# March 2021

# Load packages -----------------------------------------------------------
library(tidyverse)
library(BayesFactor)
library(pracma)
library(tie)

# Read in data ------------------------------------------------------------
# source('scripts/A_Preprocessing.R')
bothExp <- read_csv('results/data/both_experiments.csv',col_types = cols())

# Experiment 1 ------------------------------------------------------------
# Get slopes
slopes_exp1 <- bothExp %>%
  # Select data from Exp 1, only training block and A --> B transitions
  filter(expNum == 1, pairType %in% c('XX','B')) %>%
  mutate(allOnes = 1,
         babNum = factor(babNum),
         cond = factor(cond)) %>%
  group_by(babNum,cond) %>%
  # Calculate intercept and slope of RTs by baboon and condition
  bow(tie(intercept,slope) := mldivide(cbind(allOnes,trialNum),rtVal))

# Get average slope by condition
slopes_exp1 %>%
  group_by(cond) %>%
  summarize(mean(slope))

# Calculate omnibus BF
bf.exp1 <- slopes_exp1 %>%
  anovaBF(slope ~ cond + babNum, data = ., whichRandom = 'babNum')
summary(bf.exp1)

# Calculate omnibus BF without random condition
bf.exp1.nornd <- slopes_exp1 %>%
  filter(cond != 'rnd') %>%
  anovaBF(slope ~ cond + babNum, data = ., whichRandom = 'babNum')
summary(bf.exp1.nornd)
# Inverse of BF --> evidence for the null
1/bf.exp1.nornd

# Get posteriors for Exp 1
post.exp1 <- posterior(bf.exp1,iterations = 10000,columnFilter="^babNum$")
summary(post.exp1)

exp1_post.df <- as.matrix(post.exp1) %>%
  as.data.frame(.) %>%
  rename('pos1' = 'cond-pos1',
         'pos2' = 'cond-pos2',
         'pos3' = 'cond-pos3',
         'rnd' = 'cond-rnd') %>%
  select(c(pos1,pos2,pos3,rnd)) %>%
  pivot_longer(cols = c(pos1,pos2,pos3,rnd), names_to = 'condition', values_to = 'value') %>%
  mutate(condition = factor(condition,levels = c('rnd','pos1','pos2','pos3')))

# Post-hoc pairwise comparisons between conditions
exp1_pairWiseBFs <- slopes_exp1 %>%
  select(-intercept) %>%
  pivot_wider(names_from = cond,values_from = slope) %>%
  mutate(rndPos1 = pos1-rnd,
         rndPos2 = pos2-rnd,
         rndPos3 = pos3-rnd,
         pos1Pos2 = pos2-pos1,
         pos1Pos3 = pos3-pos1,
         pos2Pos3 = pos3-pos2) %>%
  pivot_longer(cols = c(rndPos1,rndPos2,rndPos3,pos1Pos2,pos1Pos3,pos2Pos3),
               names_to = 'conds',values_to='diff') %>%
  split(.$conds) %>%
  map(~ttestBF(x=.$diff,mu=0))

# Summaries of pairwise tests
1/exp1_pairWiseBFs$pos1Pos2
1/exp1_pairWiseBFs$pos1Pos3
1/exp1_pairWiseBFs$pos2Pos3
exp1_pairWiseBFs$rndPos1
exp1_pairWiseBFs$rndPos2
exp1_pairWiseBFs$rndPos3

# Experiment 2 ------------------------------------------------------------
# Get slopes for Exp. 2 and Exp. 1 grouped as a single condition
slopes_both <- bothExp %>%
  filter(pairType %in% c('XX','B'),condition != 'rndExp2') %>%
  mutate(allOnes = 1,
         babNum = factor(babNum),
         condition = factor(condition)) %>%
  group_by(babNum,condition) %>%
  bow(tie(intercept,slope) := mldivide(cbind(allOnes,trialNum),rtVal))

# Calculate omnibus BF
bf.both <- slopes_both %>%
  anovaBF(slope ~ condition * babNum, data = ., whichRandom = 'babNum')
summary(bf.both)

# Omnibus BF without random condition
bf.both.nornd <- slopes_both %>%
  filter(condition != 'rnd4') %>%
  anovaBF(slope ~ condition * babNum, data = ., whichRandom = 'babNum')
summary(bf.both.nornd)
1/bf.both.nornd

# Post-hoc pairwise tests
exp2_pairWiseBFs <- slopes_both %>%
  select(-intercept) %>%
  pivot_wider(names_from = condition,values_from = slope) %>%
  mutate(rndFix4 = fix4-rnd4,
         rndVar4 = var4-rnd4,
         rndVar5 = var5-rnd4,
         fix4Var4 = var4-fix4,
         fix4Var5 = var5-fix4,
         Var4Var5 = var5-var4) %>%
  pivot_longer(cols = c(rndFix4,rndVar4,rndVar5,fix4Var4,fix4Var5,Var4Var5),
               names_to = 'conds',values_to='diff') %>%
  filter(!is.na(diff)) %>%
  split(.$conds) %>%
  map(~ttestBF(x=.$diff,mu=0))

# Posterior distribution
post.exp2 <- posterior(bf.both,iterations = 10000,columnFilter="^babNum$")
summary(post.exp2)

exp2_post.df <- as.matrix(post.exp2) %>%
  as.data.frame(.) %>%
  rename('fix4' = 'condition-fix4',
         'var4' = 'condition-var4',
         'var5' = 'condition-var5',
         'rnd' = 'condition-rnd4') %>%
  select(c(fix4,rnd,var4,var5)) %>%
  pivot_longer(cols = c(fix4,rnd,var4,var5), names_to = 'condition', values_to = 'value') %>%
  mutate(condition = factor(condition,levels = c('rnd','fix4','var4','var5')))

# Summaries of pairwise tests
exp2_pairWiseBFs$rndFix4
exp2_pairWiseBFs$rndVar4
exp2_pairWiseBFs$rndVar5
1/exp2_pairWiseBFs$fix4Var4
1/exp2_pairWiseBFs$fix4Var5
1/exp2_pairWiseBFs$Var4Var5