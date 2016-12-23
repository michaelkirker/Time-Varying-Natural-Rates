function warning_(code,list,varargin)

if ~iswarning('var') | ~iswarning('rvar') || ~iswarning('svar')
   return
end

switch code

case -1
   msg = 'Test warning.';

case 2
   msg = '%s for non-orthogonal innovations.';

case 3
   msg = 'LR-tested VAR or VAR models have identical numbers of hyperparameters.';

case 4
   msg = 'Estimation sample reduced. Data not available for period(s)%s.';

case 7
   msg = 'Cannot reset mean for non-stationary parameterisation(s)%s.';

case 8
   msg = 'Cannot demean VAR(s) with non-stationary parameterisation(s)%s.';

case 9
   msg = 'Shock response function for reduced-form VAR.';

case 10
   msg = 'Unable to compute ACF for explosive parameterisation(s)%s.';

case 11
   msg = 'Insufficient number of observations to extend data.';
   
case 12
   msg = 'Cannot compute reverse VAR for non-statinonary parameterisation(s)%s.';

end

if nargin == 1
   list = {};
end

printmsg('VAR','warning',msg,list,code);

end