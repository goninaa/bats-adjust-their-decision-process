%Q not modified
function [negLL] = qlrn3_no_mod(x,data)
trl   =data.trial;
ch    =data.ch;
rw    =data.rw;

fxu   = @(t)(1./(1+exp(-t)));


alpha    =fxu(x(1));
beta     =fxu(x(2))*10;

ind=0;

q=zeros(2,1);
for t=1:length(trl)
ind=ind+1;
p (ind)          =(exp(beta.*(q(ch(t)))))./...
                (exp(beta.*(q(ch(t))))+...
                 exp(beta.*(q(3-ch(t)))));  
PE=(rw(t)-q(ch(t)));
q(ch(t))=q(ch(t))+alpha*PE;
end
negLL=-sum(log(p+eps));
if isnan(negLL);
    negLL=-sum(log(eps));
end