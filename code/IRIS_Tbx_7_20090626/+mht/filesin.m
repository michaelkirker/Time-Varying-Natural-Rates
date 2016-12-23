function list = filesin(directory)
% List of files in a directory.

% The IRIS Toolbox 2008/10/09.
% Copyright (c) 2007-2008 Jaromir Benes.

% =======================================================================================
%! Function body.

list = dir(directory);
list = list(~[list.isdir]);

end
% End of primary function.