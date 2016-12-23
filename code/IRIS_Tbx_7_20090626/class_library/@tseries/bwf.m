function varargout = bwf(x,order,cutoff,dates,varargin)
% To get help for this IRIS function
% * type <a href="matlab: idoc tseries.bwf">idoc tseries.bwf</a>, or
% * open <a href="matlab: helpbrowser">Matlab Product Help</a> and go the The IRIS Toolbox at the bottom of the Contents pane,

% The IRIS Toolbox 2009/03/20.
% Copyright (c) 2007-2009 Jaromir Benes.

if nargin < 4
   dates = Inf;
elseif isempty(dates)
   [varargout{1:nargout}] = deal(empty(x));
   return
end

% (lambda)/(lambda + (1/(1-L)^n)*(1/(1-(1/L))^n))

%********************************************************************
%! Function body.

order = round(order);
q = exp(-1i*2*pi/cutoff);
lambda = real((1-q).*(1-1./q))^(-order);

[varargout{1:nargout}] = filter_(x,dates,@filtersetup_,[],varargin{:},'lambda',lambda);

% End of function body.

%********************************************************************
%! Nested function filtermatrix_().

function [y,B] = filtersetup_(y,n,lambda,drift)
   p = order;
   [x,x2] = pascalrow(order,-1);
   if rem(order,2) == 0
      % Even order.
      tmp = (-1).^(0 : 2*order);
   else
      % Odd order.
      tmp = (-1).^(1 : 2*order+1);
   end
   x2 = x2 .* tmp(ones([1,order+1]),:);
   d = sum(x2,1);
   d = d(ones([1,n]),:);
   tmp = cumsum(x2,1);
   tmp(tmp == 0) = NaN;
   d(1:p+1,1:2*p+1) = tmp;
   d(end-p:end,end-2*p:end) = tmp(end:-1:1,end:-1:1);
   d = d*lambda;
   B = spdiags(d,-p:p,n,n);
   index = isnan(y);
   y(index) = 0;
   e = speye(n);
   e(index,index) = 0;
   B = B + e;
end
% End of nested function filtermatrix_()

end
% End of primary function.