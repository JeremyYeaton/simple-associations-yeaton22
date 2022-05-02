# Supplementary LMER for experiments on regularity extraction in noise in baboons
# (C) Jeremy D Yeaton
# March 2021

# Load packages -----------------------------------------------------------
library(tidyverse)
library(lme4)
library(lmerTest)

# Read in data ------------------------------------------------------------
# source('scripts/A_Preprocessing.R')
bothExp <- read_csv('data/both_experiments.csv',col_types = cols())


# Experiment 1 ------------------------------------------------------------

exp1.rnd.lmer <- bothExp %>%
  filter(expNum == 1,pairType %in% c('XX','B')) %>%
  mutate(trl20 = floor(trialNum/20)) %>%
  mutate(cond = factor(cond,levels = c('rnd','pos1','pos2','pos3'))) %>%
  lmer(rtVal ~ cond * trl20 + (trl20 + cond | name) * (1|ptPair),data=.,
       control=lmerControl(optimizer = 'bobyqa',optCtrl = list(maxfun = 100000)))
summary(exp1.rnd.lmer)

exp1.pos1.lmer <- bothExp %>%
  filter(expNum == 1,pairType %in% c('XX','B')) %>%
  mutate(trl20 = floor(trialNum/20)) %>%
  mutate(cond = factor(cond,levels = c('pos1','pos2','pos3','rnd'))) %>%
  lmer(rtVal ~ cond * trl20 + (trl20 + cond | name) + (1|ptPair),data=.,
       control=lmerControl(optimizer = 'bobyqa',optCtrl = list(maxfun = 100000)))
summary(exp1.pos1.lmer)

exp1.pos2.lmer <- bothExp %>%
  filter(expNum == 1,pairType %in% c('XX','B')) %>%
  mutate(trl20 = floor(trialNum/20)) %>%
  mutate(cond = factor(cond,levels = c('pos2','pos3','rnd','pos1'))) %>%
  lmer(rtVal ~ cond * trl20 + (trl20 + cond | name) + (1|ptPair),data=.,
       control=lmerControl(optimizer = 'bobyqa',optCtrl = list(maxfun = 100000)))
summary(exp1.pos2.lmer)

exp1.pos3.lmer <- bothExp %>%
  filter(expNum == 1,pairType %in% c('XX','B')) %>%
  mutate(trl20 = floor(trialNum/20)) %>%
  mutate(cond = factor(cond,levels = c('pos3','rnd','pos1','pos2'))) %>%
  lmer(rtVal ~ cond * trl20 + (trl20 + cond | name) + (1|ptPair),data=.,
       control=lmerControl(optimizer = 'bobyqa',optCtrl = list(maxfun = 100000)))
summary(exp1.pos3.lmer)

save.image(file='X1_LMER_models.RData')
