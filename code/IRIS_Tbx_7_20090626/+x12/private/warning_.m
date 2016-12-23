function warning_(code,list,varargin)

if iswarning('x12') == false, return, end

switch code

case 1
  msg = 'X12 can only be used with quarterly or monthly data.';

case 2
  msg  = 'Unable to perform X12 with less than 3 years of observations.';

case 3
  msg = 'Data contain within-sample NaNs.';

case 4
  msg = 'Unable to create X12 specfile.';

case 5
  msg = 'Unable to execute X12.';

case 6
  msg = 'Unable to read X12 output file.';

end

if nargin == 1, list = {}; end

printmsg('x12','warning',msg,list,code);

end