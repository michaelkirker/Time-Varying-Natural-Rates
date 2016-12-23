function d = array2db(X,range,name,logged,d)
% ARRAY2DB  Convert numeric array to database.
%
% Syntax:
%   d = array2db(X,range,name)
%   d = array2db(X,range,name,logged)
%   d = array2db(X,range,name,logged,d)
% Output arguments:
%   d [ struct ] Output database.
% Required input arguments:
%   X [ numeric ] Numeric array organised rowwise.
%   range [ numeric ] Time range, <a href="dates.html">IRIS serial date numbers</a>.
% Required input arguments for syntax (2):
%   logged [ logical | struct ] True for variables to be logarithmised.
% Required input arguments for syntax (3):
%   d [ struct ] Add output series to an existing database.

% The IRIS Toolbox 2008/10/03.
% Copyright (c) 2007-2008 Jaromir Benes.

if nargin < 4
  logged = false([1,size(X,1)]);
end

if nargin < 5
  d = struct();
end

if ~isnumeric(X) || ~isnumeric(range) || (~islogical(logged) && ~isstruct(logged)) || ~isstruct(d)
  error('Incorrect type of input argument(s).');
end

% =======================================================================================
%! Function body.

range = min(range) : max(range);
nx = size(X,1);
nalt = size(X,3);
nper = length(range);

template = tseries(range,zeros([nper,nalt]));
for i = 1 : nx
  Xi = permute(X(i,:,:),[2,3,1]);
  if (islogical(logged) && logged(i)) || (isstruct(logged) && logged.(name{i}))
    Xi = exp(Xi);
  end
  d.(name{i}) = replace(template,Xi);
end

end
% End of primary function.