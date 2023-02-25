# Figures for experiments on AB regularity extraction in noise in baboons
# (C) Jeremy D Yeaton
# March 2021

# Load packages -----------------------------------------------------------
library(tidyverse)
library(ggpubr)
library(viridis)
library(broom)

# Read in data & model objects --------------------------------------------
source('results/B_Bayesian_Analyses.R')
# Clean up workspace
rm(bf.both,bf.both.nornd,bf.exp1,bf.exp1.nornd,exp1_pairWiseBFs,
   exp2_pairWiseBFs,post.exp1,post.exp2) 

# Example RTs with slope --------------------------------------------------
# Figure 2
exemplar_toplot <- bothExp %>%
  filter(expNum == 1, pairType %in% c('XX','B')) %>%
  merge(slopes_exp1) %>%
  filter(babNum == 9) %>%
  filter(cond %in% c('rnd','pos2')) %>%
  mutate(rtEst = trialNum * slope + intercept) %>%
  group_by(cond,trialNum) %>%
  summarize(rt = mean(rtVal),
            fit = mean(rtEst),.groups='keep') %>%
  mutate(cond = case_when(cond == 'rnd' ~ 'Random',
                          cond == 'pos2' ~ 'X A B X')) %>%
  mutate(cond = factor(cond,levels=c('Random','X A B X')))

exemplar.plot <- exemplar_toplot %>%
  arrange(trialNum) %>%
  ggplot(aes(x=trialNum,color=cond)) +
  geom_path(aes(y=rt),linetype=1,alpha=.4) +
  geom_path(aes(y=fit),linetype=2,size=1) +
  theme_bw() +
  labs(x='Trial',y='Response time (ms)',color='Condition') +
  scale_color_manual(values=c('firebrick1','black')) +
  coord_cartesian(ylim=c(200,600))
exemplar.plot

# Visualize slopes --------------------------------------------------------
# Figure 3A
exp1.slopes.plot <- bothExp %>%
  filter(expNum == 1) %>%
  merge(data.frame(trialNum = 1:500) %>%
          merge(slopes_exp1, all = TRUE) %>%
          mutate(rt_est = intercept + slope * trialNum)) %>%
  mutate(cond = case_when(cond == 'rnd' ~ 'Random',
                          cond == 'pos1' ~ 'A B X X',
                          cond == 'pos2' ~ 'X A B X',
                          cond == 'pos3' ~ 'X X A B')) %>%
  mutate(cond = factor(cond, levels = c('Random','A B X X','X A B X','X X A B'))) %>%
  mutate(resids = rtVal - rt_est) %>%
  ggplot(aes(color=cond)) +
  geom_smooth(aes(x=trialNum,y=rt_est),method=lm,se=FALSE) +
  coord_cartesian(ylim = c(380,445)) +
  labs(x='Trial number',y='RT (ms)',color='Condition') +
  scale_color_viridis(discrete=TRUE,begin=0,end=.9,option='D') +
  theme_bw() +
  theme(legend.position = 'top')
exp1.slopes.plot

# Figure 4A
exp2.slopes.plot <- bothExp %>%
  filter(condition != 'rndExp2') %>%
  merge(data.frame(trialNum = 1:500) %>%
          merge(slopes_both, all = TRUE) %>%
          mutate(rt_est = intercept + slope * trialNum)) %>%
  mutate(condition=ifelse(condition=='rnd4','rnd',condition)) %>%
  mutate(condition = case_when(condition == 'rnd' ~ 'Random',
                               condition == 'fix4' ~ 'Fixed',
                               condition == 'var4' ~ 'Variable - 4',
                               condition == 'var5' ~ 'Variable - 5')) %>%
  mutate(condition = factor(condition,levels = c('Random','Fixed','Variable - 4','Variable - 5'))) %>%
  mutate(resids = rtVal - rt_est) %>%
  ggplot(aes(color=condition)) +
  geom_smooth(aes(x=trialNum,y=rt_est),method=lm,se=FALSE) +
  coord_cartesian(ylim = c(380,445)) +
  labs(x='Trial number',y='RT (ms)',color='Condition') +
  scale_color_viridis(discrete=TRUE,begin=0,end=.9,option='A') +
  theme_bw() +
  theme(legend.position = 'top')
exp2.slopes.plot


# Exp1 Density ------------------------------------------------------------
# Calculate 95% credible interval
exp1_lims <- exp1_post.df %>%
  split(.$condition) %>%
  map(~density(x=.$value)) %>%
  map_df(tidy,.id='condition') %>%
  group_by(condition) %>%
  summarize(maxy = max(y)) %>%
  merge(exp1_post.df %>%
          group_by(condition) %>%
          summarize(condMean = mean(value),
                    lowbound = quantile(value,.025),
                    highbound =quantile(value,.975)))

# Figure 3B
exp1.dense.plot <- ggplot() +
  # geom_point(aes(x=slope, y=0, color= cond),data=slopes_exp1, shape=3, size = 5) +
  geom_density(aes(x=value,color = condition),size = .75,data=exp1_post.df) +
  geom_errorbarh(aes(xmin=lowbound,xmax=highbound,y=maxy+1,color = condition),
                 size=.5,
                 height=1.25,
                 data=exp1_lims,guide=F) +
  coord_cartesian(xlim = c(-.125,.125),ylim = c(-0.5,42)) +
  labs(x='Slope',y='Posterior density',color='Condition') +
  theme_bw() +
  theme(legend.position = 'none') +
  scale_color_viridis(discrete=TRUE,begin=0,end=.9,option='D')
exp1.dense.plot

# Exp2 Density ------------------------------------------------------------
# Calculate 95% credible interval
exp2_lims <- exp2_post.df %>%
  split(.$condition) %>%
  map(~density(x=.$value)) %>%
  map_df(tidy,.id='condition') %>%
  group_by(condition) %>%
  summarize(maxy = max(y)) %>%
  merge(exp2_post.df %>%
          group_by(condition) %>%
          summarize(condMean = mean(value),
                    lowbound = quantile(value,.025),
                    highbound =quantile(value,.975)))

# Figure 4B
exp2.dense.plot <- ggplot() +
  # geom_point(aes(x=slope, y=0, color= condition),data=slopes_both, shape=3, size = 5) +
  geom_density(aes(x=value,color = condition),size = .75,data=exp2_post.df) +
  geom_errorbarh(aes(xmin=lowbound,xmax=highbound,y=maxy+1,color = condition),
                 linewidth=.5,
                 height=1.25,
                 data=exp2_lims) +
  coord_cartesian(xlim = c(-.125,.125),ylim = c(-0.5,42)) +
  labs(x='Slope',y='Posterior density',color='Condition') +
  theme_bw() +
  theme(legend.position = 'none') +
  scale_color_viridis(discrete=TRUE,begin=0,end=.9,option='A') 
exp2.dense.plot

## Save figures ####
# Figure 2
exemplar.plot %>%
  ggsave(filename = 'results/figures/exemplar.jpeg',plot=.,width= 16,height=9,units='cm')

# Figure 3
exp1.results <- ggarrange(exp1.slopes.plot,exp1.dense.plot,ncol=1,labels=c('A','B'))
exp1.results
exp1.results %>%
  ggsave('results/figures/exp1_results.jpeg',plot=.,width = 12,height=12,units='cm')

# Figure 4
exp2.results <- ggarrange(exp2.slopes.plot,exp2.dense.plot,ncol=1,labels=c('A','B'))
exp2.results
exp2.results %>%
  ggsave('results/figures/exp2_results.jpeg',plot=.,width = 12,height=12,units='cm')

## Empirical results: Supp. Fig. 1 ####
# Get hex codes for colors
scales::viridis_pal(begin=0,end=.9,option='D')(4)
scales::viridis_pal(begin=0,end=.9,option='A')(4)

slopes_box.plot <- slopes_exp1 %>%
  mutate(exp = 'Exp. 1') %>%
  rbind(slopes_both %>%
          rename(cond=condition) %>%
          mutate(exp='Exp. 2')) %>%
  mutate(cond = case_when(cond == 'pos1' ~ 'ABXX',
                          cond == 'pos2' ~ 'XABX',
                          cond == 'pos3' ~ 'XXAB',
                          cond == 'rnd' ~ 'Random',
                          cond == 'fix4' ~ 'Fixed',
                          cond == 'var4' ~ 'Variable-4',
                          cond == 'var5' ~ 'Variable-5',
                          cond =='rnd4' ~ 'Random')) %>%
  mutate(cond = factor(cond,levels=c('Random','ABXX','XABX','XXAB','Fixed','Variable-4','Variable-5'))) %>%
  ggplot() +
  geom_boxplot(aes(x=cond,y=slope,color=cond,fill=cond),alpha=0.4) +
  geom_point(aes(x=cond,y=slope,color=cond)) + 
  facet_wrap(~exp,scales = 'free_x') +
  theme_bw() +
  theme(legend.position = 'none') +
  labs(x='Condition',y='Observed slope') +
  scale_fill_manual(values=c("#440154FF", "#35608DFF", "#22A884FF", "#BBDF27FF", "#641A80FF", "#DE4968FF", "#FECE91FF")) +
  scale_color_manual(values=c("#440154FF", "#35608DFF", "#22A884FF", "#BBDF27FF", "#641A80FF", "#DE4968FF", "#FECE91FF"))
slopes_box.plot
slopes_box.plot %>%
  ggsave('results/figures/slopes_boxplot.jpeg',plot=.,width = 18,height=9,units='cm')
