function dat = zz(varargin)
% ZZ  Serial number(s) for date(s) with biannual frequency.
%
% Syntax:
%   dat = zz(year)
%   dat = zz(year,halfyear)
% Output arguments:
%   dat [ numeric ] IRIS serial date number(s).
% Required input arguments:
%   year [ numeric ] Year(s).
%   halfyear [ numeric ] Half-year(s).

% The IRIS Toolbox 2009/06/02.
% Copyright 2007-2009 Jaromir Benes.

%! Function body.

year = varargin{1};
if nargin == 1
   per = ones(size(year));
else
   per = varargin{2};
end
dat = datcode(year,per,2);

end
% End of primary function.