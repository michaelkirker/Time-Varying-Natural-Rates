function varargout = llf(x,dates,varargin)
%
% <a href="matlab: edit tseries/llf">LLF</a>  Local-level filter (random walk plus noise) with in-sample, pre-sample, and/or post-sample hard tunes.
%
% Syntax:
%    [tnd,gap] = llf(x)
%    [tnd,gap] = llf(x,dates,...)
% Output arguments:
%    tnd [ tseries ] Estimated trend component.
%    gap [ tseries ] Estimated cyclical component.
% Required input arguments:
%    x [ tseries ] Time series to be filtered.
%    dates [ numeric | Inf ] Dates to be used for filtering, i.e. <a href="dates.html">IRIS serial date numbers</a>.
% <a href="options.html">Optional input arguments:</a>
%    'drift' [ numeric | <a href="default.html">0</a> ] Drift, i.e. deterministic growth.
%    'growth' [ tseries | <a href="default.html">empty</a> ] Hard tunes imposed on the first difference of the estimated trend.
%    'lambda' [ numeric | <a href="default.html">10*get(x,'freq')</a> ] Smoothing parameter, i.e. the noise to signal variance ratio.
%    'level' [ tseries | <a href="default.html">empty</a> ] Hard tunes imposed on the level of the estimated trend.
%    'log' [ true | <a href="default.html">false</a> ] Apply filter to logged series.
%    'swap' [ true | <a href="default.html">false</a> ] Swap output arguments, i.e. [gap,tnd] = llf(...) instead of [tnd,gap] = llf(...).

% The IRIS Toolbox 2008/09/26.
% Copyright (c) 2007-2008 Jaromir Benes.

if nargin < 2
   dates = Inf;
elseif isempty(dates)
   [varargout{1:nargout}] = deal(empty(x));
   return
end

% ===========================================================================================================
%! Function body.

[varargout{1:nargout}] = filter_(x,dates,@filtersetup_,@defaultlambda_,varargin{:});

% end of function body

% ===========================================================================================================
%! Nested function filtermatrix_().

function [y,B] = filtersetup_(y,n,lambda,drift)
   d = [-lambda,2*lambda,-lambda];
   d = d(ones([1,n]),:);
   d(1,2) = lambda;
   d(end,2) = lambda;
   B = spdiags(d,-1:1,n,n);
   index = isnan(y);
   y(index) = 0;
   y(1) = y(1) - lambda*drift;
   y(end) = y(end) + lambda*drift;
   e = speye(n);
   e(index,index) = 0;
   B = B + e;
end
% End of nested function filtermatrix_().

% ===========================================================================================================
%! Nested function defaultlambda_().

function lambda = defaultlambda_(freq)
   if freq == 0
      error('No default lambda is available for time series with indeterminate frequency.');
   else
      lambda = 10*freq;
   end
end
% End of nested function defaultlambda_().

end
% End of primary function.