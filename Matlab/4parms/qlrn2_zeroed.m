%14.3.22- fixed code. beta and pexp limited between 0-10
%10.3.22- fixed night loop and beta, pexp
% Q zeroed between nights and p_val=0.5 each night 
function [negLL] = qlrn2_zeroed(x,data)
trl   =data.trial;
ch    =data.ch;
rw    =data.rw;

fxu   = @(t)(1./(1+exp(-t)));

alpha    =fxu(x(1));
beta     =fxu(x(2))*10;
Pexp     =fxu(x(3))*10;
Prate    = fxu(x(4));


Pval=[0.5,0.5];
q=zeros(2,1);
n_idx = 1:length(ch); 
[data(:).idx]=n_idx; %add index field 
data.idx=data.idx'; %transpose 
% ind=0;%***
for night=1:max(data.night); 
trl = (data.idx(data.night==night)); 
q=zeros(2,1);

for t=1:length(trl)
%     ind=ind+1;%***
    p (t)          =(exp(beta.*(q(ch(t))) + Pexp*Pval(ch(t))))./...
        (exp(beta.*(q(ch(t))) + Pexp*Pval(ch(t))) + exp(beta.*(q(3-ch(t))) + Pexp*(1-Pval(ch(t)))));
    
    Pval=(1-Prate).*Pval;
    Pval(ch(t)) = Pval(ch(t))+Prate;
%     sum(Pval)
    PE=(rw(t)-q(ch(t)));
    q(ch(t))=q(ch(t))+alpha*PE;
end
end
negLL=-sum(log(p+eps));
if isnan(negLL)==1
    negLL=0;
end
