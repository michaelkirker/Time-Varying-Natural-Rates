
function [x,f,abscissa,dens,binf,bsup] = draw_prior_density(p);
% stephane.adjemian@cepremap.cnrs.fr [07-15-2004]

pshape  = p.pshape;
p1      = p.p1;
p2      = p.p2;
p3      = p.p3;
p4      = p.p4;

truncprior = 10^(-3);
for indx=1:length(pshape);
    if pshape(indx) == 1     %/* BETA Prior */
        density = inline('((bb-x).^(b-1)).*(x-aa).^(a-1)./(beta(a,b)*(bb-aa)^(a+b-1))','x','a','b','aa','bb');
        mu = (p1(indx)-p3(indx))/(p4(indx)-p3(indx));
        stdd = p2(indx)/(p4(indx)-p3(indx));
        a = (1-mu)*mu^2/stdd^2 - mu;
        b = a*(1/mu-1);
        aa = p3(indx);
        bb = p4(indx);
        infbound = qbeta(truncprior,a,b)*(bb-aa)+aa;
        supbound = qbeta(1-truncprior,a,b)*(bb-aa)+aa;
        stepsize = (supbound-infbound)/200;
        abscissa = infbound:stepsize:supbound;
        dens = density(abscissa,a,b,aa,bb);
    elseif pshape(indx) == 2  %/* GAMMA PRIOR */
        mu = p1(indx)-p3(indx);
        b  = p2(indx)^2/mu;
        a  = mu/b;
        infbound = mj_qgamma(truncprior,a)*b;
        supbound = mj_qgamma(1-truncprior,a)*b;
        stepsize = (supbound-infbound)/200;
        abscissa = infbound:stepsize:supbound;
        dens = exp(lpdfgam(abscissa,a,b));
        abscissa = abscissa + p3(indx);
    elseif pshape(indx) == 3  %/* GAUSSIAN PRIOR */
        density = inline('inv(sqrt(2*pi)*b)*exp(-0.5*((x-a)/b).^2)','x','a','b');
        a = p1(indx);
        b = p2(indx);
        infbound = qnorm(truncprior,a,b);
        supbound = qnorm(1-truncprior,a,b);
        stepsize = (supbound-infbound)/200;
        abscissa = infbound:stepsize:supbound;
        dens = density(abscissa,a,b);
    elseif pshape(indx) == 4  %/* INVGAMMA PRIOR type 1 */
        density = inline('2*inv(gamma(nu/2))*(x.^(-nu-1))*((s/2)^(nu/2)).*exp(-s./(2*x.^2))','x','s','nu');
        nu = p2(indx);
        s  = p1(indx);
        a  = nu/2;
        b  = 2/s;
        infbound = 1/sqrt(mj_qgamma(1-10*truncprior,a)*b);
        supbound = 1/sqrt(mj_qgamma(10*truncprior,a)*b);
        stepsize = (supbound-infbound)/200;
        abscissa = infbound:stepsize:supbound;
        dens = density(abscissa,s,nu);
    elseif pshape(indx) == 5  %/* UNIFORM PRIOR */
        density = inline('(x.^0)/(b-a)','x','a','b');
        a  = p1(indx);
        b  = p2(indx);
        infbound = a;
        supbound = b;
        stepsize = (supbound-infbound)/200;
        abscissa = infbound:stepsize:supbound;
        dens = density(abscissa,a,b);
    end

    k = [1:length(dens)];
    %if pshape(indx) ~= 5
    %    [junk,k1] = max(dens);
    %    if k1 == 1 | k1 == length(dens)
    %        k = find(dens < 100);
    %    end
    %end
    binf = abscissa(k(1));
    bsup = abscissa(k(length(k)));
    x(:,indx) = abscissa(k);
    f(:,indx) = dens(k);
end;

%% Embedded function
function x = mj_qgamma(p,a)
%MJ_QGAMMA   The gamma inverse distribution function
%
%         x = mj_qgamma(p,a)

%        Anders Holtsberg, 18-11-93
%        Copyright (c) Anders Holtsberg
% MJ 02/20/04 uses lpdfgam() to avoid overflow in dgamma
%

if any(any(abs(2*p-1)>1))
    error('A probability should be 0<=p<=1, please!')
end
if any(any(a<=0))
    error('Parameter a is wrong')
end

x = max(a-1,0.1);
dx = 1;
while any(any(abs(dx)>256*eps*max(x,1)))
    %   dx = (pgamma(x,a) - p) ./ dgamma(x,a,1);
    dx = (pgamma(x,a) - p) ./ exp(lpdfgam(x,a,1));
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
function  ldens = lpdfgam(x,a,b);
% log GAMMA PDF
ldens = -gammaln(a) -a*log(b)+ (a-1)*log(x) -x/b ;

% 10/11/03  MJ adapted from an earlier GAUSS version by F. Schorfeide,
%              translated to MATLAB by R. Wouters
%              use MATLAB gammaln rather than lngam

%%
function x = qbeta(p,a,b)
%QBETA    The beta inverse distribution function
%
%         x = qbeta(p,a,b)

%       Anders Holtsberg, 27-07-95
%       Copyright (c) Anders Holtsberg

if any(any((a<=0)|(b<=0)))
    error('Parameter a or b is nonpositive')
end
if any(any(abs(2*p-1)>1))
    error('A probability should be 0<=p<=1, please!')
end
b = min(b,100000);

x = a ./ (a+b);
dx = 1;
while any(any(abs(dx)>256*eps*max(x,1)))
    dx = (betainc(x,a,b) - p) ./ dbeta(x,a,b);
    x = x - dx;
    x = x + (dx - x) / 2 .* (x<0);
    x = x + (1 + (dx - x)) / 2 .* (x>1);
end

%%
function d = dbeta(x,a,b)
%DBETA    The beta density function
%
%         f = dbeta(x,a,b)

%       Anders Holtsberg, 18-11-93
%       Copyright (c) Anders Holtsberg

if any(any((a<=0)|(b<=0)))
    error('Parameter a or b is nonpositive')
end

I = find((x<0)|(x>1));

d = x.^(a-1) .* (1-x).^(b-1) ./ beta(a,b);
d(I) = 0*I;
%%
function  x = qnorm(p,m,s)
%QNORM 	  The normal inverse distribution function
%
%         x = qnorm(p,Mean,StandardDeviation)

%       Anders Holtsberg, 13-05-94
%       Copyright (c) Anders Holtsberg

if nargin<3, s=1; end
if nargin<2, m=0; end

if any(any(abs(2*p-1)>1))
   error('A probability should be 0<=p<=1, please!')
end
if any(any(s<=0))
   error('Parameter s is wrong')
end

x = erfinv(2*p-1).*sqrt(2).*s + m;






