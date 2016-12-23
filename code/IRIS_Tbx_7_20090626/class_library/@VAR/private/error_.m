function error_(code,list,varargin)

switch code

case 1
   msg = 'Error when evaluating parameter constraints: %s';

case 2
   msg = 'LR-tested VAR models must explain the same sample.';

case 7
   msg = 'Insufficient data to simulate.';

case 8
   msg = 'Portmonteau test order must be higher than VAR order.';

case 9
   msg = 'Time series disrupted by within-sample NaNs.';

case 10
   msg = 'Insufficient number of observations.';

case 14
   msg = 'Invalid ordering vector.';

case 15
   msg = 'Unable to print reduced-form VAR as model code.';

case 16
   msg = 'Number of VAR variables and shocks must match size of input time series.';

case 17
   msg = 'Unable to run VAR/%s with multiple params or data sets in the present context.';

case 18
   msg = 'Function %s cannot be applied to reduced-form VARs.';

case 19
   msg = 'Function %s cannot be applied to VAR with multiple parameterisations.';

case 20
   msg = 'Function %s cannot be run with multiple data sets.';
   
case 21
   msg = 'Invalid size of the dummy observation matrix.';

case 22
   msg = 'Numbers of exogenised and endogenised data points do not match in period%s.';

end

if nargin == 1
   list = {};
end

printmsg('VAR','error',msg,list,code);

end