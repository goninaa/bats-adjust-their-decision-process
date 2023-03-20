% extarct alpha for each night with forget decay factor

%%%%%%
clear all
clc

%add myfolder to workingspace
addpath(genpath([pwd,'\myfolder']))
% load('myfolder\02_data\02_aggdata\data_struct.mat')
load('01 Bats with YY/myfolder/02_data/02_aggdata/data_struct.mat')
%  load('01 Bats with YY/myfolder/02_data/02_aggdata/sim_data_struct3.mat')
% load('01 Bats with YY/myfolder/02_data/02_aggdata/night4_data_struct.mat')% data seprated by nights

% fminsearch
fmin_options = optimoptions('fminunc','Display','off','Algorithm','quasi-newton',...
                            'MaxFunctionEvaluations', 100000, 'MaxIterations', 40000,...
                            'TolFun', 1e-12, 'FunValCheck','on');
                   


Niter=50; %50
parm=struct();
fxu   = @(t)(1./(1+exp(-t)));


for i=1:length(data)

    
   
    global q;
    global last_q;
    q=zeros(2,1);
    n_idx = 1:length(data{1,i}.ch); %index length
    [data{1,i}(:).idx]=n_idx; %add index field 
    data{1,i}.idx=data{1,i}.idx'; %transpose
    last_q=q;
    
    for night=1:max(data{1,i}.night); % for loop on each night 
        q=last_q; % each night starts with last night q
        
        for iter=1:Niter
    %         disp(i)
        x(1)                   =rand(1,1)*10-5;
        x(2)                   =rand(1,1)*10-5;
        x(3)                   =rand(1,1)*10-5;
        f_objective            =@(x)qlrn3_nights_forget(x, data{1,i},night);
         

        [parm_temp,negLL_temp]    =fminunc(f_objective,x,fmin_options);
        parm(night,i).subj(iter)   =unique(data{1,i}.subj);
        parm(night,i).iter(iter)   =iter;
        parm(night,i).alpha(iter)  =fxu(parm_temp(1));
        parm(night,i).beta(iter)   =fxu(parm_temp(2))*10;
        parm(night,i).negLL(iter)  =negLL_temp;
        parm(night,i).night(iter)  =night;
        parm(night,i).last_q(iter)  ={q};
       
        
        end
        x_parm  =parm(night,i);
        [~,ind] = min(x_parm.negLL);
        last_q= cell2mat(x_parm.last_q(ind));

    end
end
% 
   myparm=table();
    for i=1:length(parm)
        for night=1:max(data{1,i}.night);
            x_parm  =parm(night,i);
             [~,ind] = min(x_parm.negLL)
            myparm=[myparm;...
                   table(x_parm.subj(ind),...
                         x_parm.night(ind),...
                         x_parm.alpha(ind),....
                         x_parm.beta(ind),....
                         x_parm.negLL(ind),....
                         'VariableNames',{'subj','night','alpha','beta','negLL'})]
        end   
    end

writetable(myparm,'2parm_pf_nights_170522.csv')
