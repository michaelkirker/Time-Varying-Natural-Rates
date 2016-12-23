function [rad,per] = xsf2phase(S,freq,varargin)
%
% XS2PHASE  Convert power spectrum or spectral density function to phase shift.
%
% Syntax:
%   [rad,per] = xsf2phase(S,freq,...)
% Output arguments:
%   radian [ numeric ] Phase shift in radians.
%   period [ numeric ] Phase shift in periods.
% Required input arguments:
%   S [ numeric ] Power spectrum or spectral density function.
% <a href="options.html">Optional input arguments:</a>
%   'continuous' logical (false) If true remove discontinuities in phase shift vectors.
%
% The IRIS Toolbox 2007/05/03. Copyright 2007 Jaromir Benes. <a href="www.iris-toolbox.com">www.iris-toolbox.com</a>

%! 

default = {...
   'unwrap',false,...
   'threshold',3.5,...
};
options = passopt(default,varargin{:});

% ===========================================================================================================
%! function body

nfreq = size(S,3);

status = warning();
warning('off','MATLAB:divideByZero');
rad = atan2(imag(S),real(S));
warning(status);
if options.unwrap
   rad = unwrap(rad,[],3);
end

if nargout == 1
   return
end

per = rad;
realsmall = getrealsmall();
for i = 1 : length(freq)
   if abs(freq(i)) < realsmall
      per(:,:,i) = NaN;
   else
      per(:,:,i) = per(:,:,i) / freq(i);
   end
end

end
% end of primary function