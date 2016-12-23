function [b,stdb,e] = regress(y,x,range,varargin)
% REGRESS  Ordinary or weighted least-square regression.

% The IRIS Toolbox 2009/06/10.
% Copyright 2007-2009 Jaromir Benes.

default = {...
   'weighting',[],@(x) (isnumeric(x) && isempty(x)) || istseries(x),...
};
options = passvalopt(default,varargin{:});

if nargin < 3
   range = Inf;
end

%********************************************************************
%! Function body.

if length(range) == 1 && isinf(range)
   range = get([x,y],'minrange');
else
   range = range(1) : range(end);
end

x = rangedata(x,range);
y = rangedata(y,range);

if isempty(options.weighting)
   [b,stdb] = lscov(x,y);
else
   w = rangedata(options.weighting,range);
   [b,stdb] = lscov(x,y,w);
end

if nargout > 2
   e = tseries(range,y - x*b);
end

end
% End of primary function.