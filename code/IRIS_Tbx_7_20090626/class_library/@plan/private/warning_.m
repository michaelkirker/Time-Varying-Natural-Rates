function warning_(code,list,varargin)

if iswarning('plan') == false, return, end

switch code

case 1
  msg = 'Unable to exogenise data points: %s.';

case 2
  msg = 'Unable to endogenise data points: %s.';

case 5
  msg = 'Exogenised data points out of simulation range: %s.';

case 6
  msg = 'Endogenised data points out of simulation range: %s.';

end

if nargin == 1, list = {}; end

printmsg('plan','warning',msg,list,code);

end