function [x,varargout] = unop_(fn,x,dim,varargin)
%
% TSERIES/PRIVATE/UNOP_  Implementation of unary time series operators and functions.
%
% The IRIS Toolbox 2007/10/23. Copyright 2007 Jaromir Benes. <a href="http://www.iris-toolbox.com">www.iris-toolbox.com</a>
%

% ###########################################################################################################
%% function body

if dim == 0 % returns tseries of the same size
  [x.data,varargout{1:nargout-1}] = fn(x.data,varargin{:});
  x = cut_(x);
elseif dim == 1 % returns numeric array as a result of applying FN in first -time- dimension
  [x,varargout{1:nargout-1}] = fn(x.data,varargin{:});
else % returns a tseries shrunk in DIM as a result of applying FN in that dimension
  [x.data,varargout{1:nargout-1}] = fn(x.data,varargin{:});
  dim = size(x.data);
  x.comment = cell([1,dim(2:end)]);
  x.comment(:) = {''};
  x = cut_(x);
end

end
%% end of primary function