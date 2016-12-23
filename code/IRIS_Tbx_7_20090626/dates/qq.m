function dat = qq(varargin)
%
% QQ  Serial number(s) for date(s) with quarterly frequency.
%
% Syntax:
%   dat = qq(year)
%   dat = qq(year,quarter)
% Output arguments:
%   dat [ numeric ] IRIS serial date number(s).
% Required input arguments:
%   year [ numeric ] Year(s).
%   quarter [ numeric ] Quarter(s).
%
% The IRIS Toolbox 2007/09/27. Copyright 2007 Jaromir Benes. <a href="http://www.iris-toolbox.com">www.iris-toolbox.com</a>
%



% ###########################################################################################################
%% function body

year = varargin{1};
if nargin == 1
  per = ones(size(year));
else
  per = varargin{2};
end
dat = datcode(year,per,4);

end
% end of primary function