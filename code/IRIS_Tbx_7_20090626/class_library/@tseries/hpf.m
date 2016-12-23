function varargout = hpf(x,dates,varargin)
% To get help for this IRIS function
% * type <a href="matlab: idoc tseries.hpf">idoc tseries.hpf</a>, or
% * open <a href="matlab: helpbrowser">Matlab Product Help</a> and go the The IRIS Toolbox at the bottom of the Contents pane,

% The IRIS Toolbox 2008/10/07.
% Copyright (c) 2007-2008 Jaromir Benes.

if nargin < 2
   dates = Inf;
elseif isempty(dates)
   [varargout{1:nargout}] = deal(empty(x));
   return
end

%********************************************************************
%! Function body.

[varargout{1:nargout}] = ...
   filter_(x,dates,@filtersetup_,@defaultlambda_,varargin{:});

% End of function body.

%********************************************************************
%! Nested function filtermatrix_().

function [y,B] = filtersetup_(y,n,lambda,drift)
   d = [1,-4,6,-4,1];
   d = d(ones([1,n]),:);
   d(1,:) = [1,-2,1,NaN,NaN];
   d(2,:) = [1,-4,5,-2,NaN];
   d(end,:) = d(1,end:-1:1);
   d(end-1,:) = d(2,end:-1:1);
   d = d*lambda;
   B = spdiags(d,-2:2,n,n);
   index = isnan(y);
   y(index) = 0;
   e = speye(n);
   e(index,index) = 0;
   B = B + e;
end
% End of nested function filtermatrix_()

%********************************************************************
%! Nested function defaultlambda_().

function lambda = defaultlambda_(freq)
   if freq == 0
      error('No default lambda is available for time series with indeterminate frequency.');
   else
      lambda = 100*freq^2;
   end
end
% End of nested function defaultlambda_().

end
% End of primary function.