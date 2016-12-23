function x = db2tseries(d,list)
% DB2TSERIES  Retrieve array of time series from database.
%
% Syntax:
%   x = db2tseries(d,list)
% Output arguments:
%   x [ tseries ] Mutlivariate time series.
% Required input arguments:
%   d [ struct ] Database from which to retrieve time seris.
%   list [ cellstr | char ] List of time series to retrieve.

% The IRIS Toolbox 2009/03/19.
% Copyright 2007-2009 Jaromir Benes.

if ischar(list)
   list = charlist2cellstr(list);
end

%********************************************************************
%! Function body.

x = [];
for i = 1 : length(list)
   x = [x,d.(list{i})];
end

end
% End of primary function.