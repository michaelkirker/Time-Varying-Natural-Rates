function x = normalise(x,normdate,varargin)
%
% <a href="tseries/normalise">NORMALISE</a>  Normalise data to particular date.
%
% Syntax:
%   x = normalise(x)
%   x = normalise(x,normdate,...)
% Output arguments:
%   x [ tseries ] Normalised times series.
% Required input arguments:
%   x [ tseries ]  Input time series to be normalised.
%   normdate [ numeric | char ] Date w.r.t. which time series will be normalised.
% <a href="options.html">Optional input arguments:</a>
%   'mode' [ 'add' | <a href="default.html">'mult'</a> ]  Additive or multiplicative mode.
%
% The IRIS Toolbox 2008/01/09. Copyright 2007-2008 Jaromir Benes. <a href="http://www.iris-toolbox.com">www.iris-toolbox.com</a>
% _______________________________________________________________________________

default = {
  'mode','mult',@(x) any(strcmpi(x,{'add','mult'})),...
};
options = passvalopt(default,varargin{:});

if nargin == 1
  normdate = 'nanstart';
end

%% function body --------------------------------------------------------------------------------------------

fn = iff(strcmpi(options.mode,'add'),@minus,@rdivide);

if ischar(normdate)
  normdate = get(x,normdate);
end

[x.data,dim] = reshape_(x.data);
y = getdata_(x,normdate);
for i = 1 : size(x.data,2)
  x.data(:,i) = fn(x.data(:,i),y(i));
end
x.data = reshape_(x.data,dim);

end

%% end of primary function ----------------------------------------------------------------------------------