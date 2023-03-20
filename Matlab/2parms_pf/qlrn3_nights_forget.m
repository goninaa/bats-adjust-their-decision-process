%16.5.22- extract each night alpha with forget decay between
%nights
%16.3.22- 2 parms model
 
function [negLL] = qlrn3_nights_forget(x,data,night)
global q
global last_q


ch    =data.ch;
rw    =data.rw;

fxu   = @(t)(1./(1+exp(-t)));


alpha    =fxu(x(1));
beta     =fxu(x(2))*10;
forget   =fxu(x(3));


trl = (data.idx(data.night==night)); %run only on trials from specific night
 q=last_q*forget;  
ind=0;
for t=1:length(trl)
ind=ind+1;    
p (ind)          =(exp(beta.*(q(ch(t)))))./...
                (exp(beta.*(q(ch(t))))+...
                 exp(beta.*(q(3-ch(t)))));  
PE=(rw(t)-q(ch(t)));
q(ch(t))=q(ch(t))+alpha*PE;


end
negLL=-sum(log(p+eps));
if isnan(negLL)==1
    negLL=0;
end
