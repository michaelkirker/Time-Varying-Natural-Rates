function dec = dat2dec(dat)
%
% DAT2DEC  Convert serial date number(s) to decimal representation(s).
%
% Syntax:
%   dec = dat2dec(dat)
% Output arguments:
%   dec [ numeric ] Decimal representation(s) of date(s): year + (per-1)/freq.
% Required input arguments:
%   dat [ numeric ] <a href="dates.html">IRIS serial date number(s)</a>.

% The IRIS Toolbox 2008/09/30.
% Copyright (c) 2007-2008 Jaromir Benes.

% ===========================================================================================================
%! Function body.

[year,per,freq] = dat2ypf(dat);

if freq == 0
   dec = per;
else
   dec = year + (per-1)./freq;
   % Centre dates in the middle of the period.
   % This is used for interpolation grids.
   if nargin > 2 && centre
      dec = dec + 1./(2*freq);
   end
end

end
% End of primary function.