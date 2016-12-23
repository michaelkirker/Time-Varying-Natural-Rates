function warning_(code,list,varargin)

if iswarning('model') == false, return, end

switch code

case 1
  msg = 'Cannot find/match this variable name: "%s".';

case 2
  msg = 'This parameter is not available: "%s".';

case 3
  msg = 'Steady state may not be accurate for "%s".';

case 4
  msg = 'Log declarations disregarded in linear models.';

case 7
  msg = 'Invalid assignment of parameters.';

case 8
  msg = 'Time series not available for: "%s".';

case 12
  msg = 'Parameter changed since last steady state and/or solution: "%s".';

case 13
  msg = 'Cannot get growth rates for non-linear models.';

case 14
  msg = 'Numerical instability. Status not reliable for: "%s".';

case 15
  msg = 'No anchored variable(s) or no free residual(s). Plain simulation run instead.';

case 18
  msg = '%sidentified anchoring system. (Data points exogenized: %g. Data points endogenized: %g.)';

case 19
  msg = 'Model solution expanded forward to t+%g.';

case 20
  msg = 'Model solution not available. Use SOLVE first.';

case 21
  msg = 'No effect of anticipated residuals (backward-looking model).';

case 22
  msg = 'Numerical inaccuracy in Schur decomposition. SEVN2 patch applied.';

case 23
  msg = 'Forward expansion already available up to t+%g.';

case 25
  msg = 'Cannot fix steady state for this variable: "%s".';

case 26
  msg = 'Solution not available: No stable solution for parameterisation(s)%s.';

case 27
  msg = 'Solution not available: Multiple stable solutions for parameterisation(s)%s.';

case 28
  msg = 'Not enough information to compute some of diffuse initial conditions or out-of-likelihood parameters.';

case 29
  msg = 'Solution not available: Complex derivatives in parameterisation(s)%s.';

case 30
  msg = 'Cannot evaluate IF..THEN..ELSE expression: "%s". FALSE used instead.';

case 31
  msg = 'Cannot find parameter "%s".';

case 32
  msg = 'Solution not available: State-space form has singularity in parameterisation(s)%s.';

case 33
  msg = 'Solution not available: NaN derivatives in parameterisation(s)%s.';

case 34
  msg = 'Log-linear variable has non-positive steady state: "%s".';

case 35
  msg = 'Steady state for this variables is not available from database: "%s".';

case 36
  msg = 'Cannot find this equation label: "%s".';

case 37
  msg = 'Symbolic Math Toolbox not installed. Cannot calculate symbolic derivatives.';

case 39
  msg = 'Unrecognised objective function.';

case 40
  msg = 'Underdetermined conditional forecast system(s). Forecast(s) not computed for setup(s)%s.';

case 41
  msg = 'Unable to use large scale method for objective functions other than -loglik.';

case 42
  msg = 'Convergence not reached after %g iteration(s). Model solution and optimal rule are inaccurate.';

case 43
  msg = 'Unable to plug optimal rule into original model. Using iterated policy function instead.';

case 44
  msg = 'Solution not available for setup(s)%s.';

case 45
  msg = 'Forward expansion not available for setup(s)%s.';

case 46
  msg = 'Parameter disregarded because its lower bound >= upper bound: "%s".';

case 47
  msg = 'Option REMOVEZEROSTD=true ignored when retrieving state space for multiple parameterisations.';

case 48
  msg = 'No parameters to be optimised.';

case 49
  msg = 'Starting value for parameter "%s" reset to its upper bound.';

case 50
  msg = 'Starting value for parameter "%s" reset to its lower bound.';

case 51
   msg = 'No measurement data available for Kalman filter run(s)%s.';
   
case 52
  msg = 'Cannot evaluate some of the symbolic derivative(s) of this equation. Numerical derivative(s) will be used instead: "%s"';
   
case 53
   msg = 'No steady-state value returned for "%s".';

case 54
   msg = 'Some observables are non-stationary. Cannot evaluate spectrum generating function for parameterisation(s)%s.';

end

if nargin == 1
  list = {};
end

printmsg('model','warning',msg,list,code);

end