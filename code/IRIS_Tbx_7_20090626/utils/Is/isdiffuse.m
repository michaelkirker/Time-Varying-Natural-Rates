function varargout = isdiffuse(eigval,varargin)
% Detect non-stationary variables.

% The IRIS Toolbox 2008/10/14.
% Copyright (c) 2007-2008 Jaromir Benes.

% =======================================================================================
%! Function body.

realsmall = getrealsmall();
index = find(abs(abs(eigval) - 1) <= realsmall);
for i = 1 : nargin - 1
  varargout{i} = vech(any(abs(varargin{i}(:,index)) > realsmall,2));
end

end
% End of primary function.