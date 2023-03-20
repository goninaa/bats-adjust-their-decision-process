%24.4.22- alpha per night
%14.3.22- fixed code. beta and pexp limited between 0-10
%Q not modified
%%%%%%
clear all
clc

%add myfolder to workingspace
addpath(genpath([pwd,'\myfolder']))
load('01 Bats with YY/myfolder/02_data/02_aggdata/data_struct.mat')





% fminsearch
fmin_options = optimoptions('fminunc','Display','off','Algorithm','quasi-newton',...
                            'MaxFunctionEvaluations', 100000, 'MaxIterations', 40000,...
                            'TolFun', 1e-12, 'FunValCheck','on');
                   


Niter=100; %50
parm=struct();
fxu   = @(t)(1./(1+exp(-t)));


for i=1:length(data)
     for iter=1:Niter
     
       
    x(1)                   =rand(1,1)*10-5; %alpha
    x(2)                   =rand(1,1)*10-5; %beta
    x(3)                   =rand(1,1)*10-5; %pexp
    x(4)                   =rand(1,1)*10-5; %prate
    x(5)                   =rand(1,1)*10-5; %decay parameter- used only in partly forget model
              f_objective            =@(x)qlrn2(x, data{1,i}); %no mod
%              f_objective            =@(x)qlrn2_partly_forget(x, data{1,i}); % partly forget
%              f_objective            =@(x)qlrn2_zeroed(x, data{1,i}); % zeroed Q
    [parm_temp,negLL_temp]    =fminunc(f_objective,x,fmin_options);
    parm(1,i).subj(iter)   =unique(data{1,i}.subj);
    parm(1,i).iter(iter)   =iter;
    parm(1,i).alpha(iter)  =fxu(parm_temp(1));
    parm(1,i).beta(iter)   =fxu(parm_temp(2))*10;
    parm(1,i).Pexp(iter)   =fxu(parm_temp(3))*10;
    parm(1,i).Prate(iter)  =fxu(parm_temp(4));
    parm(1,i).negLL(iter)     =negLL_temp;

    end
end
myparm=table();
for i=1:length(parm)
    x  =parm(1,i);
    [~,ind] = min(x.negLL) %find the first minimal negLL index
    myparm=[myparm;...
           table(x.subj(ind),...
                 x.alpha(ind),....
                 x.beta(ind),....
                 x.Pexp(ind),....
                 x.Prate(ind),....
                 x.negLL(ind),....
                  'VariableNames',{'subj','alpha','beta','Pexp','Prate','LL'})]
%                  'VariableNames',{'subj','alpha','beta','Pexp','Prate','negLL'})]
end

writetable(myparm,'parms_no_mod_night2_100iter.csv')
%  writetable(myparm,'parms_zeroed_030422_50iter.csv')
% struct ('myparm_GN', myparm)
