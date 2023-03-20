# 18.7.22 change betas to nightly betas
# 18.7.22- softmax policy fix (were missing "()")
#13.5.22- inital Q changed to 0.5 (was 0.01)
#12.5.22-  changed to bats new data betas- pf model

#16.9.21- define beta as beta from bats' real lowered Q model (f_q) betas (100 sims to each beta in each alpha)
# 11.9.21- define beta as beta from bats' real  z_q betas (3 sims to each beta in each alpha) 
#4.9.21
# 2000 trials total (insted of 503) 
#26.1.21
###adapting to volatile simulations. ###
#added beta generated from gaussion disterbution based on real 
# (stable) bats data.
#multi-agents
#multi-alphas
# add replacement of feeders
#fixed softmax policy (25.1)


import numpy as np 
import pandas as pd 
import math


class Environment:
    """initialize environment properties: env= environment condition ('Stable' or 'Volatile'), probs= feeders' reward probability (list)
        k= number of feeder"""
    def __init__(self,env= 'Stable', probs = [0.8,0.2]):
        # Number of feeders
        self.k = len(probs)
        # sucess probabilities for each feeder
        self.probs = probs
        self.env = env

    def step (self,action):
        # take an action and get stochastic reward (1 for success, 0 for failure)
        return 1 if (np.random.random()  < self.probs[action]) else 0
   
        
class Agent:
    """agent properties: nActions= number of possible actions (int,defult= 2), init Q values, alphe, beta.
        agent select feeder and update Q values"""
     
    def __init__(self,alpha,beta,agent_id):
        # Number of possible actions?
        self.nActions = 2
        # Q values
        self.q = [0.5,0.5]
        self.alpha = alpha
        # self.beta = generate_beta_gauss('fast')
        self.beta = beta #fixed beta or from a list
        self.agent_id = agent_id
        
    
    def update_q(self, action, reward):
        """Update Q (state-action-value) given (action, reward)"""
        pe = reward - self.q[action]
        self.q[action] = self.q[action] + self.alpha * pe
        # print ('Q:', self.q)

    def select_feeder (self): 
        """select a feeder based on soft-max policy"""
        prob_action_0 = (math.exp((self.beta)* self.q[0]))/((math.exp((self.beta)* self.q[0]))+(math.exp((self.beta)* self.q[1])))
        rand_num = np.random.random() # float between 0-1
        # print ('P(a0):', prob_action_0)
        if prob_action_0 >= rand_num:
            return 0
        elif prob_action_0 < rand_num:
            return 1

    def get_action_dummy (self): #for debugging only!
        """for dubgging only! it's a dummy policy """
        if self.q[0]> self.q[1]:
            return 0
        elif self.q[0]< self.q[1]:
            return 1
        elif self.q[0] == self.q[1]:
            return np.random.randint(2)

class Simulation:
    """simulation of a specific agent in environment"""
    def __init__(self, env_a, env_b, agent, N_steps_a, N_steps_b, total_trials=503):
        self.env_a = env_a
        self.env_b = env_b
        self.agent = agent
        # self.probs = probs
        self.N_steps_a = N_steps_a
        self.N_steps_b = N_steps_b
        self.total_trials = total_trials
        self.df =  pd.DataFrame(columns=['subj','Step','Total steps','Action', 'Reward', 'Q_Value_A0', 'Q_Value_A1','Reward_p','Alpha','Beta'])

# Start simulation
    def run(self):

        count_trials = 0
        while count_trials<total_trials:

            # self.df = self.df.append({'subj': agent.agent_id ,'Alpha': agent.alpha,'Beta': agent.beta}, ignore_index=True)        
            for episode_a in range(self.N_steps_a):
                action = self.agent.select_feeder() # sample policy
                # print ('choosen action:',action)
                reward = self.env_a.step(action) # take step + get reward
                # print ('reward:',reward)
                # print ('Q before:', agent.q)
                count_trials+=1
                self.df = self.df.append({'subj': agent.agent_id ,'Step': episode_a+1,'Total steps': count_trials,'Action': action,'Reward': reward, 'Q_Value_A0': agent.q[0],'Q_Value_A1': agent.q[1],
                                            'Reward_p': self.env_a.probs, 'Alpha': agent.alpha,'Beta': agent.beta}, ignore_index=True) #q-value before action!
                self.agent.update_q(action, reward) # update Q

            for episode in range(self.N_steps_b):
                action = self.agent.select_feeder() # sample policy
                reward = self.env_b.step(action) # take step + get reward
                # print ('reward:',reward)
                # print ('Q before:', agent.q)
                count_trials+=1
                self.df = self.df.append({'subj': agent.agent_id ,'Step': episode+1,'Total steps': count_trials,'Action': action,'Reward': reward, 'Q_Value_A0': agent.q[0],'Q_Value_A1': agent.q[1],
                                            'Reward_p': self.env_b.probs, 'Alpha': agent.alpha,'Beta': agent.beta}, ignore_index=True) #q-value before action!
                self.agent.update_q(action, reward) # update Q
    
        return self.df


if __name__ == "__main__":

    # create beta list
    b_v= pd.read_csv('/Users/gonina/Dropbox/feeders_exp/results/new data/2parms_fixed/2parms_pf_nights_with_env_170522.csv')
    # b_v= pd.read_csv('/Users/gonina/Dropbox/feeders_exp/results/new data/2parms_fixed/2parms_models_030422.csv')
    # b_v= list(b_v[b_v['env']=='fast']['beta_pf'])
    # b_v= list(b_v[b_v['env']=='slow']['beta_pf'])
    # b_v= list(b_v[b_v['env']=='Stable']['beta']) #54 betas
    # b_v= list(b_v[b_v['env']=='Volatile']['beta']) #36 betas
    # print (b_v)
    # b_v= pd.read_csv('/Users/gonina/Dropbox/lab (goni)/python_codes/feeders_analysis_git/feeders_analysis/data/beta_volatile_bats.csv') #volatile bats' betas from zeroed Q model- might not be accurate betas (15.9.21)
    # b_v = b_v['beta_z'].to_list()
    # print (f"betas: {b_v}")
    
    # Settings
    probs_a = [0.8,0.2] # bandit arm probabilities of success
    probs_b = [0.2,0.8] # bandit arm probabilities of success
    #19.7.22- 3 N_experiments for volatile and 2 for stable
    #17.9.21- 11 N_experiments for volatile and 7 for stable
 
    # # #volatile
    b_v= list(b_v[b_v['env']=='Volatile']['beta']) #36 betas
    N_experiments = 3
    #****N_steps needs to be 13- changed to 100 for debugging
    N_steps_a = 13 # number of steps (episodes) for cond a (calculated by total trials/total hours which is about 14 trials per hour/switch)
    N_steps_b = 13 # number of steps (episodes) for cond b

    # stable:
    # b_v= list(b_v[b_v['env']=='Stable']['beta']) #54 betas
    # N_experiments = 2
    # N_steps_a = 251 #251 number of steps (episodes) before feeders replacement #real slow bats mean is 251 trials for night1+night2
    # N_steps_b = 214 #214 number of steps (episodes) after feeders replacement #real slow bats mean is 214 trials for night3+night4
    # 
    total_trials = 2000 # total trials average for volatile bats is 503 per bat (in sim will be 504)- changed to 2000 (2002 trials becouse it's 13 trials to env)
    alphas = np.arange(0,1.1,0.1)
    # alphas= [0.14]#0.14 volatile or 0.22 stable
    betas = b_v
    


    # initializing:
    env_a = Environment(probs= probs_a) # initialize arm probabilities
    env_b = Environment(probs= probs_b)

    #runnig different alphas for multipy bats:

    for alpha in alphas:
        agents_sim = {} #dict of all agents simulations
        subj_id = 1
        for beta in betas:
            #number of experiments to perform (number of same parameters bats)
            for subj in range(N_experiments): 
                agent = Agent(alpha=alpha,beta=beta, agent_id=subj_id)  # initialize agent
                simulation = Simulation(env_a,env_b, agent, N_steps_a, N_steps_b) #running simulatiom for each agent
                df = simulation.run()
                agents_sim[subj_id]=df
                # print (subj_id)
                subj_id +=1
                # print (agents_sim)

        #concat all agents df
        agents_df = pd.DataFrame()
        for key in agents_sim.keys():
            agents_df = agents_df.append(agents_sim[key])

        # agents_df.to_csv(f'stable_sim_alpha_{round(alpha,2)}_stable_pf_betas.csv')
        agents_df.to_csv(f'volatile_sim_alpha_{round(alpha,2)}_.csv')
        # agents_df.to_csv(f'stable_sim_alpha_{round(alpha,2)}_.csv')







   

