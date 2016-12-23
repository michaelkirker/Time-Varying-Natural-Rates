function a = pct(x,varargin)
%
% PCT  Percentage rate of change.
%
% Syntax:
%   x = pct(x)          (1)
%   x = pct(x,shift)    (2)
% Output arguments:
%   x [ tseries ] Percentage rate of change in input series.
% Required input arguments:
%   x [ tseries ] Input series.
% Required input arguments for syntax (2):
%   shift [ numeric ] Time shift, i.e lag (negative value) or lead (positive value).
%
% Nota bene:
%   Syntax (2) assumes shift=-1.
%
% The IRIS Toolbox 2007/10/23. Copyright 2007 Jaromir Benes. <a href="http://www.iris-toolbox.com">www.iris-toolbox.com</a>
% _______________________________________________________________________________

if nargin > 1 && ~isnumeric(varargin{1})
  error('Incorrect type of input argument(s).');
end

%% function body --------------------------------------------------------------------------------------------

a = unop_(@pct_,x,0,varargin{1:end});

end

%% end of primary function ----------------------------------------------------------------------------------