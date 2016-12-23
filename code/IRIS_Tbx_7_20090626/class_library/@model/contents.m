% The IRIS Toolbox.
% Copyright (c) 2007-2008 Jaromir Benes.
%
% <a href="matlab: idoc model">Model functions.</a>
% 
% Type
%   idoc model/FUN
% to open HTML documentation for the function FUN.
% 
% Creating model objects:
% 
%   <a href="matlab: idoc model/model">model</a>           - Read model code file and create new model object.
% 
% Getting information about model objects:
% 
%   <a href="matlab: idoc model/get">get</a>             - Access properties of model object.
%   <a href="matlab: idoc model/islinear">islinear</a>        - True if model is declared as linear.
%   <a href="matlab: idoc model/isnan">isnan</a>           - Check for NaNs in model object.
%   <a href="matlab: idoc model/isstationary">isstationary</a>    - True if there are no unit roots in model transition matrix.
%   <a href="matlab: idoc model/length">length</a>          - Number of alternative parameterisations.
%   <a href="matlab: idoc model/size">size</a>            - Size of model state space.
%   <a href="matlab: idoc model/sspace">sspace</a>          - State-space representation of model.
%   <a href="matlab: idoc model/system">system</a>          - Unsolved system matrices.
% 
% Solving models:
% 
%   <a href="matlab: idoc model/chksstate">chksstate</a>       - Check if model equations hold for currently assigned steady state.
%   <a href="matlab: idoc model/expand">expand</a>          - Expand model solution forward up to to t+k.
%   <a href="matlab: idoc model/solve">solve</a>           - Compute first-order accurate reduced-form solution.
%   <a href="matlab: idoc model/sstate">sstate</a>          - Compute steady state.
%   <a href="matlab: idoc model/tcorule">tcorule</a>         - Time-consistent (discretionary) optimal rule.
% 
% Simulating models, and examining deterministic properties:
% 
%   <a href="matlab: idoc model/diffsrf">diffsrf</a>         - Differentiate shock response functions w.r.t. selected parameters.
%   <a href="matlab: idoc model/eig">eig</a>             - Model eigenvalues sorted in ascending order of moduli.
%   <a href="matlab: idoc model/forecast">forecast</a>        - Unconditional and conditional forecasts.
%   <a href="matlab: idoc model/icrf">icrf</a>            - Response function to initial conditions.
%   <a href="matlab: idoc model/ifrf">ifrf</a>            - Frequency response function to input signals in residuals.
%   <a href="matlab: idoc model/reporting">reporting</a>       - Evaluate reporting equations.
%   <a href="matlab: idoc model/resample">resample</a>        - Resample from model-implied distribution.
%   <a href="matlab: idoc model/simulate">simulate</a>        - Simulate model.
%   <a href="matlab: idoc model/srf">srf</a>             - Response function to shocks.
% 
% Identifying and estimating models, and filtering data:
% 
%   <a href="matlab: idoc model/bn">bn</a>              - Beveridge-Nelson decomposition.
%   <a href="matlab: idoc model/diffloglik">diffloglik</a>      - Score vector and information matrix for selected parameters.
%   <a href="matlab: idoc model/estimate">estimate</a>        - Estimate model parameters by optimising selected objective function.
%   <a href="matlab: idoc model/filter">filter</a>          - Kalman smoother and estimator of out-of-likelihood parameters.
%   <a href="matlab: idoc model/loglik">loglik</a>          - Evaluate likelihood function in time domain.
% 
% Examining second-moment properties:
% 
%   <a href="matlab: idoc model/acf">acf</a>             - Autocovariance and autocorrelation function for model variables.
%   <a href="matlab: idoc model/acfd">acfd</a>            - Autocovariance function decomposition into contributions of shocks.
%   <a href="matlab: idoc model/fevd">fevd</a>            - Forecast error variance decomposition for model variables.
%   <a href="matlab: idoc model/ffrf">ffrf</a>            - Frequency response function of transition variables to measurement variables.
%   <a href="matlab: idoc model/fmse">fmse</a>            - Forecast mean square errors.
%   <a href="matlab: idoc model/vma">vma</a>             - VMA representation of model.
%   <a href="matlab: idoc model/xsf">xsf</a>             - Power spectrum and spectral density function for model variables.
% 
% Handling data associated with models:
% 
%   <a href="matlab: idoc model/db2dp">db2dp</a>           - Convert database to model-specific datapack.
%   <a href="matlab: idoc model/dp2db">dp2db</a>           - Convert model-specific datapack to database.
%   <a href="matlab: idoc model/emptydb">emptydb</a>         - Create model-specific empty database.
%   <a href="matlab: idoc model/sstatedb">sstatedb</a>        - Model-specific steady-state database.
%   <a href="matlab: idoc model/zerodb">zerodb</a>          - Model-specific zero database.
% 
% Other functions:
% 
%   <a href="matlab: idoc model/assign">assign</a>          - Assign, or re-assign, parameters and/or steady states.
%   <a href="matlab: idoc model/findeqtn">findeqtn</a>        - Find equations by equation labels or by matching regular expression with equation labels.
%   <a href="matlab: idoc model/fprintf">fprintf</a>         - Write formatted steady-state values and/or parameters to file.
%   <a href="matlab: idoc model/sprintf">sprintf</a>         - Write formatted steady-state values and/or parameters to string.
%   <a href="matlab: idoc model/stdscale">stdscale</a>        - Re-scale std deviations by a common factor.
%   <a href="matlab: idoc model/userdata">userdata</a>        - Get or set user data attached to a model object.
% 