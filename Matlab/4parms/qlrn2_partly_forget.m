%14.3.22- fixed code. beta and pexp limited between 0-10
%10.3.22-fixed night loop
%Q partly forget- not finished writing
function [negLL] = qlrn2_partly_forget(x,data)
% trl   =data.trial;
ch    =data.ch;
rw    =data.rw;
% night = data.night;

fxu   = @(t)(1./(1+exp(-t)));


alpha    =fxu(x(1));
beta     =fxu(x(2))*10;
Pexp     =fxu(x(3))*10;
Prate    = fxu(x(4));
forget   =fxu(x(5)); %added parameter- can only be between 0 to 1

Pval=[0.5,0.5];
q=zeros(2,1);
n_idx = 1:length(ch); %new
[data(:).idx]=n_idx; %add index field 
data.idx=data.idx'; %transpose
for night=1:max(data.night); 
    trl = (data.idx(data.night==night)); 
    q=q*forget;  
    for t=min(trl):max(trl) % only current nights trials(changed)
        
        p (t)          =(exp(beta.*(q(ch(t))) + Pexp*Pval(ch(t))))./...
            (exp(beta.*(q(ch(t))) + Pexp*Pval(ch(t))) + exp(beta.*(q(3-ch(t))) + Pexp*(1-Pval(ch(t)))));
        
        Pval=(1-Prate).*Pval;
        Pval(ch(t)) = Pval(ch(t))+Prate;
        %     sum(Pval)
        PE=(rw(t)-q(ch(t)));
        q(ch(t))=q(ch(t))+alpha*PE;
        %     disp(t)
    end
end
negLL=-sum(log(p+eps));
if isnan(negLL)==1
    negLL=0;
end


% length(data(1).night(data(1).night==1))