# -*- coding: utf-8 -*-
"""
Created on Thu Nov 23 2020

@author: Jeremy D Yeaton
"""

import os, numpy as np, pandas as pd, pickle
os.chdir('C:\\Users\\LPC\\Documents\\JDY\\NADs\\exp2\\input')

transTimes = pd.read_csv('..\\..\\exp1\\results\\exp1_rndTimes.csv')
meanRTmaster = np.mean(transTimes['time'])
sdRt = np.std(transTimes['time'])

babNames = ["ANGELE","ARIELLE","ARTICHO","ATMOSPHERE","CAUET","DORA","DREAM",\
            "EWINE","FANA","FELIPE","FEYA","FLUTE","HARLEM","HERMINE","KALI",\
                "LIPS","LOME","MAKO","MALI","MUSE","NEKKE","VIOLETTE","0",\
                    "PIPO","BOBO","PETOULETTE"] # B06 & Brigitte are dead
nBabs = len(babNames)
# Shuffle baboons
np.random.shuffle(babNames)

# Define structure positions
strucs3 = [[0,1],[1,2],[2,3]]
strucs4 = [[0,1],[1,2],[2,3],[3,4]]

# All possible positions:
positions = [1,2,3,4,5,6,7,8,9]
#%%
# select different transitions for different monkeys
# for each triplet should have more or less the same response time
# for each triplet, take avg, std, and range
# less than 10 ms rt difference
# three pairs with no overlap
# make sure average is constant over AB, CD, and EF over all monkeys
#%% Permute pairings
'''
For each baboon, select 2 pairs of points for which: 
 - the range of RTs under random conditions is not greater than 10ms
 - the mean RT of the pairs is not more than 1.5 SD from the overall mean
It will continue to reshuffle until these conditions are met

It will then count how many times each pair appears across all of the baboons, 
and report if any pair appears more than 5 times

It returns 2 [n baboons x 3] lists:
    pos1: first position in regularities for each baboon
    pos2: second position in regularities for each baboon
    rt: transition time in random sequencing to go from position 1 to position 2
'''
j = 0
allTrips = []
dcheck = 0
for bab in range(nBabs):
    dupCheck, rtCheck = 0,0
    while dupCheck + rtCheck != 2:
        samp = transTimes.sample(n = 2, replace = False)
        dupCheck = 0
        rtCheck = 0
        p1 = [i for i in samp['Pos1']]
        p2 = [i for i in samp['Pos2']]
        sameP1 = p1[0] == p1[1]
        sameP2 = p2[0] == p2[1]
        anyDup = False
        for i in p1:
            if i in p2:
                anyDup = True
                break
        if sameP1 or sameP2 or anyDup:
            j+=1
        else:
            dupCheck = 1
        rts = [i for i in samp['time']]
        leftover = abs(np.mean(rts) - meanRTmaster)
        if max(rts) - min(rts) > 5 or leftover > (1.5*sdRt):#
            j+=1
        else:
            rtCheck = 1
        if dupCheck + rtCheck == 2:
            allTrips.append(samp)
print('Number of tries: ' + str(j))
## %% Extract pairs and rts
pos1 = []
pos2 = []
rt = []
for bab in range(nBabs):
    samp = allTrips[bab]
    pos1.append([i for i in samp['Pos1']])
    pos2.append([i for i in samp['Pos2']])
    rt.append([i for i in samp['time']])

d = {}
for i in range(len(pos1)):
    p1 = pos1[i]
    p2 = pos2[i]
    for j in range(len(p1)):
        reg = str([p1[j],p2[j]])
        if reg in d:
            d[reg] += 1
        else:
            d[reg] = 1
for key in d:
    if d[key] > 3:
        print('Failed: '+ key + ': ' + str(d[key]))
        dcheck = 1
print(len(d))
if dcheck == 0:
    print('Succcess!')
#%% Save successful run
pairDict = {'pos1': pos1,
            'pos2': pos2,
            'rt': rt,
            'd': d}
f = open('pairDict_exp2.pkl', "wb")
pickle.dump(pairDict, f)
f.close()
#%% Assign to monkeys and write files
'''
For each baboon, output a file comprised of 1400 trials:
 - 200 random trials of length == 4
 - 500 trials with regularity (reg1) randomly in sequence of length == 4
 - 200 random trials of length == 5
 - 500 trials with regularity (reg2) randomly in sequence of length == 5

The master file is then subdivided into files of 100 trials each
'''
# Load in pairs that satisfy constraints (same as in exp1)
f = open('pairDict_exp2_max3.pkl', "rb")
pairDict = pickle.load(f)
f.close()
pos1 = pairDict['pos1']
pos2 = pairDict['pos2']
rt = pairDict['rt']

# Create metadata file
g = open('metaInfo.txt','w')
g.write('babName\t order\t reg1\t reg1RT\t reg2\t reg2RT\t meanRT\n')

# Loop over baboons
grpIdx = 0
lengths = [4,5]
for bab in range(nBabs):
    babName = babNames[bab]
    
    if bab > 13:
        lengths = [5,4]
    
    # Assign regularity pairs to baboon
    AB = [pos1[bab][0],pos2[bab][0]]
    CD = [pos1[bab][1],pos2[bab][1]]
    regs = [AB, CD]
    
    np.random.shuffle(regs)
    
    # Remove regularity items from 'positions' to avoid repetition
    posAB = positions.copy()
    posCD = positions.copy()
    for i in range(2):
        posAB.remove(AB[i])
        posCD.remove(CD[i])
        
    # Write meta data
    meanRT = round(np.mean(rt[bab]),2)
    g.write('\t'.join([babName,str(lengths),str(regs[0]),str(round(rt[bab][0],2)),str(regs[1]),\
                       str(round(rt[bab][1],2)),str(meanRT)])+'\n')
  
    # Open trials master file    
    f = open('master\\'+babName+'.txt','w')
    
    for lenIdx, length in enumerate(lengths):
        # Build random block
        rndBlock = np.zeros((200,16),dtype = int)
        for i in range(len(rndBlock)):
            rndBlock[i,:length] = np.random.choice(positions,size=(1,length),replace=False)
        
        # Write random blocks to master
        for i in range(len(rndBlock)):
            # Line must begin with test,1,4, and end with ,[BLOCKNAME]
            f.write('test,1,' + str(length) + ',')
            for j in range(np.shape(rndBlock)[1]):
                f.write(str(rndBlock[i,j])+',')
            f.write('random'+str(length)+'\n')
        
        # Produce starting state random trials for test blocks
        reg = regs[lenIdx]
        testBlk = np.zeros((500,16),dtype = int)
        blkPos = positions.copy()
        for i in range(2):
            blkPos.remove(reg[i])
        for i in range(500):
            testBlk[i,:length] = np.random.choice(blkPos,size=(1,length),replace=False)
        
        # Make randomized list of where AB will appear for each trial
        locations = [i for i in range(length - 1)]
        locAll = locations*round(500/len(locations))
        repCheck = False
        j = 1
        while repCheck == False:
            np.random.shuffle(locAll)
            rep = 1
            maxRep = 0
            for tIdx in range(1,len(locAll)):
                if locAll[tIdx] == locAll[tIdx-1]:
                    rep += 1
                else:
                    rep = 1
                if rep > maxRep:
                    maxRep = rep
            j += 1
            if maxRep < 5:
                repCheck = True
                print('Tries: ' + str(j))
        
        # Assign AB at the random position for each trial
        block = np.copy(testBlk)
        
        for i in range(len(block)):
            block[i,locAll[i]] = reg[0]
            block[i,locAll[i] + 1] = reg[1]
        
        # Make sure there are no duplicate touches in a line
        for i in range(len(block)):
            if len(set(block[i,:])) != length + 1:
                print('Error! Repeated touch in a trial!')
                
        # Write trials to master file
        for i in range(len(block)):
            f.write('test,1,' + str(length) + ',')
            for j in range(np.shape(block)[1]):
                f.write(str(block[i,j])+',')
            f.write('RegLen'+str(length)+'\n')
    f.close()
g.close()

##%%
# Divide long files into 100 trial chunks
for bab in range(nBabs):
    babName = babNames[bab]
    f = open('master\\'+babName+'.txt','r')
    allLines = []
    for line in f:
        allLines.append(line)
    for Idx, line in enumerate(allLines):
        if Idx % 100 == 0:
            g.close()
            g = open('blocks100\\'+babName+'_'+str(int((Idx/100)+1))+'.txt','w')
        g.write(line)
    g.close()
print('Done!')
