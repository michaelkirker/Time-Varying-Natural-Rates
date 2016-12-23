function marginal = marginal_density(simulations,lposterior)

[N,npara]=size(simulations);

lpost_mode = max(lposterior);

MU = mean(simulations)';
SIGMA = zeros(npara,npara);
for i=1:N;
    SIGMA = SIGMA + (simulations(i,:)'-MU)*(simulations(i,:)'-MU)';
end;
SIGMA = SIGMA/N;

DetSIGMA = det(SIGMA);
InvSIGMA = inv(SIGMA);
marginal = [];

for p = 0.1:0.1:0.9;
    critval = qchisq(p,npara);
    tmp = 0;
    for i = 1:N;
        deviation  = (simulations(i,:)-MU')*InvSIGMA*((simulations(i,:)-MU'))';
        if deviation <= critval;
	  lftheta = -log(p)-(npara*log(2*pi)+log(DetSIGMA)+deviation)/2;
	  tmp = tmp + exp(lftheta - lposterior(i)+lpost_mode);
        end;    
    end;
    marginal = cat(1,marginal,[p,lpost_mode-log(tmp/N)]); 
end;    
marginal=-mean(marginal(:,2));   

%EMBEDDED FUNCTIONS
%%
function x = qchisq(p,a)
%QCHISQ   The chisquare inverse distribution function
%
%         x = qchisq(p,DegreesOfFreedom)

%        Anders Holtsberg, 18-11-93
%        Copyright (c) Anders Holtsberg

if any(any(abs(2*p-1)>1))
   error('A probability should be 0<=p<=1, please!')
end
if any(any(a<=0))
   error('DegreesOfFreedom is wrong')
end

x = qgamma(p,a*0.5)*2;
%%
function x = qgamma(p,a)
%QGAMMA   The gamma inverse distribution function
%
%         x = qgamma(p,a)

%        Anders Holtsberg, 18-11-93
%        Copyright (c) Anders Holtsberg

if any(any(abs(2*p-1)>1))
   error('A probability should be 0<=p<=1, please!')
end
if any(any(a<=0))
   error('Parameter a is wrong')
end

x = max(a-1,0.1);
dx = 1;
while any(any(abs(dx)>256*eps*max(x,1)))
   dx = (pgamma(x,a) - p) ./ dgamma(x,a,1);
   x = x - dx;
   x = x + (dx - x) / 2 .* (x<0);
end

I0 = find(p==0);
x(I0) = zeros(size(I0));
I1 = find(p==1);
x(I1) = zeros(size(I1)) + Inf;
%%
function F = pgamma(x,a)
%PGAMMA   The gamma distribution function
%
%         F = pgamma(x,a)

%       Anders Holtsberg, 18-11-93
%       Copyright (c) Anders Holtsberg

if any(any(a<=0))
   error('Parameter a is wrong')
end

F = gammainc(x,a);
I0 = find(x<0);
F(I0) = zeros(size(I0));
%%
function f = dgamma(x,a,b)
%DGAMMA   The gamma density function
%
%         f = dgamma(x,a)

%       Anders Holtsberg, 18-11-93
%       Copyright (c) Anders Holtsberg

if any(any(a<=0))
   error('Parameter a is wrong')
end

f = (x./b) .^ (a-1) .* exp(-x./b) ./ (b.*gamma(a));
I0 = find(x<0);
f(I0) = zeros(size(I0));
%%
