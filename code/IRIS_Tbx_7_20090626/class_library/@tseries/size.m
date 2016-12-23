function varargout = size(this,varargin)
% <a href="tseries/size">SIZE</a>  Size of time series.
%
% Syntax
%   s = size(x)
%   [m,n,...] = size(x)
%   n = size(x,k)
% Output arguments for syntax (1):
%   s [ numeric ] Size of time series, s = [m,n,...].
% Output arguments for syntax (2):
%   m [ numeric ] Size of time series in individual dimensions.
% Output arguments for syntax (3):
%   n [ numeric ] Size of time series in queried dimension.
% Required input arguments:
%   x [ tseries ] Time series.
% Required input arguments for syntax (3):
%   k [ numeric ] Queried dimension.

% The IRIS Toolbox 2008/10/05.
% Copyright (c) 2007-2009 Jaromir Benes.

%********************************************************************
%! Function body.

% Call from variable editor 2008b or higher.
if isVariableEditor_()
   [varargout{1:nargout}] = variableEditor_('size',this,varargin{:});
   return
end

s = size(this.data);
if nargin > 1
   s(end+1:max(varargin{1})) = 1;
   varargout{1} = s(varargin{1});
elseif nargout > 1
   s(end+1:nargout) = 1;
   for i = 1 : nargout
      varargout{i} = s(i);
   end
else
   varargout{1} = s;
end

end
% End of primary function.