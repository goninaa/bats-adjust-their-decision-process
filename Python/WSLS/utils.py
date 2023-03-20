import numpy as np
import pandas as pd

# utility funcation for configuration, simulation, storing 

def create_reward_probs(n_action,trials_block,total_trails,p_option):
    reward_probs = np.zeros(shape=(n_action,total_trails))
    
    for b in range(int(total_trails/trials_block)):
        
        start = b*trials_block
        end = (b+1)*trials_block
        p_best = np.random.choice(p_option)
        if p_best > .5:
            p_bad = .5
        else:
            p_bad = .1
            
        b_h = np.random.choice([0,1])
        
        reward_probs[b_h,start:end] = np.repeat(p_best,trials_block)
        reward_probs[1-b_h,start:end] = np.repeat(p_bad,trials_block)
        
    return reward_probs


def configuration_parameters():
    # configuration 2 free parameters (α, β)     
    parameters = {
                'alpha_1' : np.random.uniform(0, 1), # alpha_1 =: learning rate for the selected action
                'alpha_2' : np.random.uniform(0, 1), # alpha_2 =: forgetting rate for the action not chosen
                'kappa_1' : np.random.uniform(0, 5), # kappa_1 =: strength of reinforcement by reward
                'kappa_2' : np.random.uniform(0, 5), # kappa_2 =: strength of the aversion resulting from the no-reward
                
    }
    return parameters



class DataOfSim():
    # this class stores all the data of one simulation
    # storing the following: action_1, stage_2_state, transation_type, action_2, reward

    def __init__ (self , num_of_trials):
        self.n_trial =  np.zeros(num_of_trials,dtype=int)
        self.drift_0 = np.zeros(num_of_trials,dtype=np.float32)
        self.drift_1 = np.zeros(num_of_trials,dtype=np.float32)

        self.action = np.zeros(num_of_trials,dtype=int)
        self.reward = np.zeros(num_of_trials,dtype=np.float32) 
        self.probs_action_0 = np.zeros(num_of_trials,dtype=np.float32)
        self.probs_action_1 = np.zeros(num_of_trials,dtype=np.float32)
        self.q_0 = np.zeros(num_of_trials,dtype=np.float32)
        self.q_1 = np.zeros(num_of_trials,dtype=np.float32)
        self.theta_0 = np.zeros(num_of_trials,dtype=np.float32)
        self.theta_1 = np.zeros(num_of_trials,dtype=np.float32)
        self.theta_2 = np.zeros(num_of_trials,dtype=np.float32)
        self.theta_3 = np.zeros(num_of_trials,dtype=np.float32)
        self.theta_4 = np.zeros(num_of_trials,dtype=np.float32)
        
    def createDic(self):
        dic = {
                'n_trial':self.n_trial,
                'drift_0' : self.drift_0,
                'drift_1' : self.drift_1,
                'action' : self.action,
                'reward' : self.reward,
                'probs_action_0' : self.probs_action_0,
                'probs_action_1': self.probs_action_1,
                'q_0': self.q_0,
                'q_1': self.q_1,       
                'theta_0': self.theta_0,       
                'theta_1': self.theta_1,       
                'theta_2': self.theta_2,              
                'theta_3': self.theta_3,
                'theta_4': self.theta_4
            }
        return dic 