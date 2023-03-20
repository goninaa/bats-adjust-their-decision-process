%16.3.22- 2 parms model
%10.3.22- fixed night loop and beta, pexp
% Q zeroed between nights and p_val=0.5 each night 
function [negLL] = qlrn3_zeroed(x,data)
trl   =data.trial;
ch    =data.ch;
rw    =data.rw;

fxu   = @(t)(1./(1+exp(-t)));
% fxp   = @(t)exp(t);

alpha    =fxu(x(1));
beta     =fxu(x(2))*10;



Pval=[0.5,0.5];
q=zeros(2,1);
n_idx = 1:length(ch); 
[data(:).idx]=n_idx; %add index field 
data.idx=data.idx'; %transpose 
for night=1:max(data.night); 
trl = (data.idx(data.night==night)); 
q=zeros(2,1);
ind=0;
for t=1:length(trl)
ind=ind+1;    
p (ind)          =(exp(beta.*(q(ch(t)))))./...
                (exp(beta.*(q(ch(t))))+...
                 exp(beta.*(q(3-ch(t)))));  
PE=(rw(t)-q(ch(t)));
q(ch(t))=q(ch(t))+alpha*PE;
end
end
negLL=-sum(log(p+eps));
if isnan(negLL)==1
    negLL=0;
end
