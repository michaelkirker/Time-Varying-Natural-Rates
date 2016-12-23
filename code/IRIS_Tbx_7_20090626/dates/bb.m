function dat = bb(varargin)
%
% BB  Serial number(s) for date(s) with bimonthly frequency.
%
% Syntax:
%   dat = bb(year)
%   dat = bm(year,bimonth)
% Output arguments:
%   dat [ numeric ] IRIS serial date number(s).
% Required input arguments:
%   year [ numeric ] Year(s).
%   bimonth [ numeric ] Bimonth(s).
%
% The IRIS Toolbox 2007/09/27. Copyright 2007 Jaromir Benes. <a href="http://www.iris-toolbox.com">www.iris-toolbox.com</a>
% _______________________________________________________________________________

%% function body --------------------------------------------------------------------------------------------

year = varargin{1};
if nargin == 1
  per = ones(size(year));
else
  per = varargin{2};
end
dat = datcode(year,per,6);

end

%% end of primary function ----------------------------------------------------------------------------------