function [fcn,h0] = constrain(p0,lb,ub)

if ub < lb
  error('Lower bound must not exceed upper bound.');
end

% set k so that dh/dp = 1 at p = p0;

if lb == ub
  fcn.unc2con = @(h) lb;
  fcn.dcon2dunc = @(h) 0;
  fcn.con2unc = @(p) NaN;
  fcn.dunc2dcon = @(p) Inf;
elseif isinf(lb) && isinf(ub)
  fcn.unc2con = @(h) h;
  fcn.dcon2dunc = @(h) 1;
  fcn.con2unc = @(p) p;
  fcn.dunc2dcon = @(p) 1;
elseif ~isinf(lb) && isinf(ub)
  fcn.unc2con = @(h) lb + exp(h);
  fcn.dcon2dunc = @(h) exp(h);
  fcn.con2unc = @(p) log(p - lb);
  fcn.dunc2dcon = @(p) 1./(p - lb);
elseif isinf(lb) && ~isinf(ub)
  fcn.unc2con = @(h) ub - exp(h);
  fcn.dcon2dunc = @(h) -exp(h);
  fcn.con2unc = @(p) log(ub - p);
  fcn.dunc2dcon = @(p) 1./(ub - p);
else
  fcn.unc2con = @(h) (atan(h)/pi + 1/2)*(ub-lb) + lb;
  fcn.dcon2dunc = @(h)  1./(1+h.^2)./pi.*(ub-lb);
  fcn.con2unc = @(p) -tan(1/2*pi*(2*p-ub-lb)./(-ub+lb));
  fcn.dunc2dcon = @(p) -(1+tan(1/2*pi*(2*p-ub-lb)./(-ub+lb)).^2)*pi./(-ub+lb);
end

h0 = fcn.con2unc(p0);

end