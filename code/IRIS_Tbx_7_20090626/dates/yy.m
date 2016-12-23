function dat = yy(varargin)
%
% YY  Serial number(s) for date(s) with annual frequency.
%
% Syntax:
%   dat = yy(year)
% Output arguments:
%   dat [ numeric ] IRIS serial date number(s).
% Required input arguments:
%   year [ numeric ] Year(s).
%
% The IRIS Toolbox 2007/05/03. Copyright 2007 Jaromir Benes. <a href="www.iris-toolbox.com">www.iris-toolbox.com</a>

%% function body --------------------------------------------------------------------------------------------

year = varargin{1};
if nargin == 1
  per = ones(size(year));
else
  per = varargin{2};
end
dat = datcode(year,per,1);

end

%% end of primary function ----------------------------------------------------------------------------------