function this = moving(this,varargin)
%
% <a href="tseries/moving">MOVING</a>  Apply function to moving window.
%
% Syntax:
%   this = moving(this)
%   this = moving(this,range,...)
% Output arguments:
%   this [ tseries ] Output time series.
% Required input arguments:
%   this [ tseries ] Input time series.
% <a href="options.html">Optional input arguments:</a>
%   'function' [ function_handle | <a href="default.html">@mean</a> ] Function to be applied to moving window of numbers.
%   'window' [ numeric | <a href="default.html">-get(this,'freq')+1:0</a> ] Window, i.e. a set of lags and/or leads.

% The IRIS Toolbox 2007/08/31.
% Copyright 2007 Jaromir Benes.

if nargin == 1
   range = Inf;
elseif (nargin > 1 && ischar(varargin{1}))
   range = Inf;
else
   range = setrange(varargin{1});
   varargin(1) = [];
end

default = {
   'window',-datfreq(this.start)+1:0,@isnumeric,...
   'function',@mean,@(x) isa(x,'function_handle'),...
};
options = passvalopt(default,varargin{1:end});

% ===========================================================================================================
%! function body

if ~(length(range) == 1 && isinf(range))
   this = resize(this,range);
end
this = unop_(@moving_,this,0,options.window,options.function);

end
% end of primary function