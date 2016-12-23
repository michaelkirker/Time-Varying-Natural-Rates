function fval=postln(Theta,m,d,p,deviation)

global p;

%Checking whether the draw is within parameter bounds
if all(p.p3<Theta & Theta<p.p4)==0;
        fval=Inf;
        return;
end

%Evaluating the (log) prior distribution
pri=priorln(Theta,p.pshape,p.p1,p.p2);

for i=1:length(p.name);
    m=assign(m,p.name{i},Theta(i));
end;

[m,npath]=solve(m);
if npath~=1;
     fval=Inf;
%      p.counter = p.counter + 1;                    %%%%%%%%%%%%%%%
%      disp(p.counter)
      return;
end;
%Evaluating the (negative) (log) likelihood
L = loglik(m,d,p.range,'deviation',eval(deviation),'output','dbase');

%minus (log) Posterior
fval    = (L-pri);



