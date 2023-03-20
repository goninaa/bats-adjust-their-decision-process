import numpy as np
import pandas as pd
from utils import *

def wsls_sim(parameters, num_of_trials, reward_probs):

    # set up parameters 
    p_stay_win = parameters[0]
    p_shift_lose = parameters[1]
   

    # store data from each trial 
    data = DataOfSim(num_of_trials)

    for t in range(num_of_trials):
        if t == 0:
            # chose first action randomly 
            p = np.array([.5,.5])
        else:
            if rLast == 1:
                # win stay with probability p_stay_win
                p[aLast] = p_stay_win
                p[1-aLast] = 1 - p_stay_win
            else:
                # loss shift with probability p_shift_lose
                p[1-aLast] = p_shift_lose
                p[aLast] = 1 - p_shift_lose
        
        # choose an action according to action probabilities
        action = np.random.choice([0,1] , p=p)
                
        # check if the trial is rewarded
        r_0, r_1 = 1-reward_probs[action, t], reward_probs[action, t]
        reward = np.random.choice([0,1], p=[r_0,r_1])
        
        # last trial infromation
        aLast = action  
        rLast = reward

        # stroe data of the trial
        data.n_trial[t] = t  
        data.drift_0[t] = reward_probs[0, t]
        data.drift_1[t] = reward_probs[1, t]

        data.action[t] = action
        data.reward[t] = reward
        data.probs_action_0[t] = p[0]
        data.probs_action_1[t] = p[1]

        data.theta_0[t] = p_stay_win
        data.theta_1[t] = p_shift_lose

    df = pd.DataFrame(data.createDic())
    return df