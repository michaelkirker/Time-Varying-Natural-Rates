function dat = qqtoday()
% <a href="dates/qqtoday">QQTODAY</a>  IRIS serial date number for current quarter.
%
% Syntax:
%    dat = qqtoday()
% Output arguments:
%    dat [ numeric ]  Serial number for current quarter.

% The IRIS Toolbox 2008/12/23.
% Copyright (c) 2007-2008 Jaromir Benes.

% =======================================================================================
%! Function body.

[year,month] = datevec(now());
dat = qq(year,1+floor((month-1)/3));

end
% End of primary function.