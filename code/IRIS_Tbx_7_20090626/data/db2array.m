function [X,notfound,invalid] = db2array(d,range,name,shift,loglin,precision)
% DB2ARRAY  Convert time series from database to numeric array.

% The IRIS Toolbox 2008/10/10.
% Copyright (c) 2007-2008 Jaromir Benes.

if nargin < 4
   shift = zeros(size(name));
end

if nargin < 5
   loglin = false(size(name));
end

if nargin < 6
   precision = 'double';
end

if ~isstruct(d) || ~isnumeric(range) || (length(range) == 1 && isinf(range)) || ~isnumeric(shift) || ~islogical(loglin) || ~ischar(precision)
   error('Incorrect type of input argument(s).');
end

%********************************************************************
%! Function body.

nx = length(name);
range = range(1) : range(end);
nper = length(range);
notfound = {};
invalid = {};
X = [];
for i = 1 : nx
   if isfield(d,name{i}) && istseries(d.(name{i}))
   	Xi = rangedata(d.(name{i}),range+shift(i));
      if isempty(X)
         X = nan([nx,nper,size(Xi,2)],precision);
      end
      naltx = size(X,3);
      naltxi = size(Xi,2);
      % If needed, expand number of alternatives
      % in current array or current addition.
      if naltx == 1 && naltxi > 1
         X = X(:,:,ones([1,naltxi]));
         naltx = naltxi;
      elseif naltx > 1 && naltxi == 1
         Xi = Xi(:,ones([1,naltx]));
         naltxi = naltx;
      end
      if naltx == naltxi
         if loglin(i)
            Xi = log(Xi);
         end
         X(i,:,1:naltxi) = permute(Xi,[3,1,2]);
      else
         invalid{end+1} = name{i};
      end
   else
      notfound{end+1} = name{i};
   end
end

if isempty(X)
   X = nan([nx,nper],precision);
end

end
% End of primary function.