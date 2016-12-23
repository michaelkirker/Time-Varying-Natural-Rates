function lnprior = priorln(para, pshape, p1, p2)
% Orginal author: Frank Schorfheide 
% This procedure computes a prior density for
% the structural parameters of the DSGE models
% pshape: 1 is BETA(mean,stdd)
%         2 is GAMMA(mean,stdd)
%         3 is NORMAL(mean,stdd)
%         4 is INVGAMMA(s,nu)
%         5 is UNIFORM [lower,upper]
% p1=First argument   p2= Second argument

lnprior = 0;
nprio = length(pshape);

i = 1;
while i <=  nprio;
a = 0;
b = 0;

   if pshape(i) == 1;     %  BETA Prior 
     a = (1-p1(i))*p1(i)^2/p2(i)^2 - p1(i);
     b = a*(1/p1(i) - 1);
     lnprior = lnprior + log(betapdf(para(i),a,b));
     
   elseif pshape(i) == 2; % GAMMA PRIOR 
     b = p2(i)^2/p1(i);
     a = p1(i)/b;
     lnprior = lnprior + log(gampdf(para(i),a,b));
     
   elseif pshape(i) == 3; % GAUSSIAN PRIOR 
     lnprior = lnprior + log(normpdf(para(i),p1(i),p2(i)));
     
   elseif pshape(i) == 4; % INVGAMMA PRIOR 
       s=p1(i);
       nu=p2(i);
       x=para(i);
       lnprior = lnprior + log(2) - gammaln(nu/2) - (nu/2).*log(2/s) - (nu+1)*log(x) - .5*s./(x.^2);
   elseif pshape(i) == 5; % UNIFORM PRIOR 
     lnprior = lnprior + log(1/(p2(i)-p1(i)));
     
   end;
  i = i+1;
end;