function error_(code,list,varargin)

switch code

case 7
  msg = 'NaN or Inf occured when evaluating "%s".';

case 16
  msg = 'Unmatched curly braces in "%s"';

case 25
  msg = 'Initial condition for this variables not available from input data: "%s".';

case 26
  msg = 'Exogenised data point(s) for this variables not available from input data: "%s".';

case 32
  msg = 'SSTATE can handle stationary or difference-stationary models only.';

case 33
  msg = 'Simulatenous use of anticipated and unanticipated anchors not implemented.';

case 34
  msg = 'Plan range and simulation range must agree.';

case 37
  msg = 'Multiple equal signs in equation: "%s".';

case 43
  msg = 'Cannot fix steady state for this variables because it is NaN: "%s".';

case 44
  msg = 'Number of data sets and parameterisations must match.';

case 46
  msg = 'Incorrect number of parameterisations or steady states or time series: "%s".';

case 47
  msg = 'Cannot run MODEL/%s with multiple paremeterisations or data sets.';

case 48
  msg = 'Number of parameterisations must be at least 1.';

case 51
  msg = 'Cannot simulate with this combination of options:%s.';

case 56
  msg = 'Last filter period and first forecast period must be two consecutive dates.';

case 58
  msg = 'Size of weighting matrix or vector must agree with number of measurement variables.';

case 59
  msg = 'Weighting matrix or vector must have at least one non-zero entry.';

case 60
  msg = 'Variable name "%s" not found in model.';

case 61
  msg = 'Equation label "%s" not found in model.';

case 62
  msg = 'Number of instruments must match number of equations dropped from model.';

case 63
  msg = 'Weighting matrix must be symmetric.';

case 64
  msg = 'Cannot estimate out-of-likelihood parameters with option "dtrends" set to false.';

case 66
  msg = 'Input datapack is not consistent with model structure.';

case 68
  msg = 'Parameter name "%s" not found in model.';

end

if nargin == 1
  list = {};
end

printmsg('model','error',msg,list,code);

end