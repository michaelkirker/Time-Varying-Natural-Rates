function warning_(code,list,varargin)

if iswarning('dbase') == false, return, end

switch code

case 1
  msg = 'Database entry name corrected when reading %s: "%s" >> "%s".';

case 2
  msg = 'Unable to create following database entry when reading %s: "%s".';

case 3
  msg = 'Unable to apply function to database entry: "%s".';

case 4
  msg = 'Error(s) when evaluating DBBATCH expression: "%s".$n$t%s';

case 5
  msg = 'Warning(s) when evaluating DBBATCH expression: "%s".';

case 6
  msg = 'Unable to save database entry: "%s".';

case 7
  msg = 'Unable to find or fetch time series: "%s".';

end

if nargin == 1, list = {}; end

printmsg('dbase','warning',msg,list,code);

end