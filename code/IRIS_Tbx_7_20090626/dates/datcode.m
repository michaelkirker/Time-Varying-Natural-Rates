function dat = datcode(year,per,freq)
%
% <a href="dates/datcode.m">DATCODE</a>  IRIS serial date number.
%
% Syntax:
%   dat = datcode(y,p,f)
% Arguments:
%   y [ numeric ] Year.
%   p [ numeric ] Period within year.
%   F [ numeric ] Frequency (total number of periods within year).

% The IRIS Toolbox 2008/09/30.
% Copyright (c) 2007-2008 Jaromir Benes.

% =======================================================================================
%! Function body.

dat = year.*freq + per - 1 + freq/100;

if any(freq(:) == 0)
   if length(freq) == 1
      dat(:) = per(:);
   else
      index = freq == 0;
      dat(index) = per(index);
   end
end

end
% End of primary function.