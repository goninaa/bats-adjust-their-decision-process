
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
                   


Niter=50;
parm=struct();
fxu   = @(t)(1./(1+exp(-t)));


for i=1:length(data)

    for iter=1:Niter
%         disp(i)
    x(1)                   =rand(1,1)*10-5;
    x(2)                   =rand(1,1)*10-5;
    x(3)                   =rand(1,1)*10-5;
    f_objective            =@(x)qlrn3_no_mod(x, data{1,i});%no mod
%         f_objective            =@(x)qlrn3_zeroed(x, data{1,i});%zeroed

    [parm_temp,negLL_temp]    =fminunc(f_objective,x,fmin_options);
    parm(1,i).subj(iter)   =unique(data{1,i}.subj);
    parm(1,i).iter(iter)   =iter;
    parm(1,i).alpha(iter)  =fxu(parm_temp(1));
    parm(1,i).beta(iter)   =fxu(parm_temp(2))*10;
    parm(1,i).negLL(iter)     =negLL_temp;

    end
end
myparm_no_mod=table();
for i=1:length(parm)
    x  =parm(1,i);
     [~,ind] = min(x.negLL)

%     display (x.subj(ind))
    myparm_no_mod=[myparm_no_mod;...
           table(x.subj(ind),...
                 x.alpha(ind),....
                 x.beta(ind),....
                 x.negLL(ind),....
                 'VariableNames',{'subj','alpha','beta','negLL'})]
end

% writetable(myparm_no_mod,'2parm_no_mod_night4.csv')
% writetable(myparm_no_mod,'2parm_pf_030422.csv')