function [Phi,Psi,s,c] = srf(this,time)
%
% <a href="matlat: edit VAR/srf">SRF</a>  Innovation (shock) response function.
%
% Syntax:
%   [Phi,Psi,s,c] = srf(this,nper)
%   [Phi,Psi,s,c] = srf(this,range)
% Output arguments:
%   Phi [ numeric ] VMA representation of VAR model.
%   Psi [ numeric ] Cumulative VMA.
%   s [ tseries ] Forecast error responses as multivariate time series.
%   c [ tseries ] Cumulative forecast error responses as multivariate time series.
% Required input arguments:
%   this [ VAR ] VAR model.
% Required input arguments for syntax (1):
%   nper [ numeric ] Number of periods.
% Required input arguments for syntax (2):
%   range [ numeric ] Time range (<a href="dates.html">IRIS serial date numbers</a>).
%
% The IRIS Toolbox 2007/10/10. Copyright 2007 Jaromir Benes. <a href="http://www.iris-toolbox.com">www.iris-toolbox.com</a>

%!

% tell whether time is nper or range
if length(time) == 1 && round(time) == time && time > 0
   range = 1 : time;
else
   range = time(1) : time(end);
end
nper = length(range);

% ===========================================================================================================
%! function body

try
   % Try to import Time Domain package directory.
   import('time_domain.*');
end

Phi = var2vma(this.A,this.B,nper);
Psi = cumsum(Phi,3);
if nargout > 2
   s = tseries(range,permute(Phi,[3,1,2,4]));
end
if nargout > 3
   c = tseries(range,permute(Psi,[3,1,2,4]));
end

end
% end of primary function
