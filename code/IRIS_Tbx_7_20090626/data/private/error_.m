function error_(code,list,varargin)
%
% The IRIS Toolbox 2007/05/03. Copyright 2007 Jaromir Benes. <a href="www.iris-toolbox.com">www.iris-toolbox.com</a>

switch code

case 2
  msg = 'Unable to retrieve database entry: %s.';

case 3
  msg = 'Invalid name found when reading database %s: ''%s''.';

case 4
  msg = 'Incorrect size of vector time series: %s.';

end

if nargin == 1, list = {}; end

printmsg('dbase','error',msg,list,code);

end