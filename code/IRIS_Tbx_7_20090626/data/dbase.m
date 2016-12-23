function d = dbase(name,value)
%
% The IRIS Toolbox 2007/05/03. Copyright 2007 Jaromir Benes. <a href="www.iris-toolbox.com">www.iris-toolbox.com</a>

if nargin > 1 & (~iscellstr(name) || iscell(value))
  error('Incorrect type of input argument(s).');
end

% function body ---------------------------------------------------------------------------------------------

if nargin == 2
  d = cell2struct(vech(name),vech(value),2);
else
  d = struct();
end

end % of primary function -----------------------------------------------------------------------------------