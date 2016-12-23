function [m,smooth,se2,delta,pe,f] = filter(m,data,varargin)
%
% <a href="matlab: edit model/filter">FILTER</a>  Kalman smoother and estimator of out-of-likelihood parameters.
%
% Syntax:
%   [m,smooth,se2,delta,pe,F] = filter(m,dpack...)
%   [m,smooth,se2,delta,pe,F] = filter(m,dbase,range...)
% Output arguments:
%   m [ model ] Model solved with estimated parameters (see options 'relative' and 'outoflik').
%   smooth [ struct ] Datapack or databases (depending on 'output' option) with mean and MSE or std.deviations.
%   se2 [ numeric ] Estimated common variance factor (if option 'relative' is true).
%   delta [ struct ] Database with point estimates of out-of-likelihood parameters.
%   pe [ struct ] Prediction errors associated with measurement variables.
%   f [ struct ] Std.deviations of prediction errors.
% Required input arguments:
%   m [ model ] Model.
%   dpack [ cell | numeric ] Datapack or numeric array with measurement variables (organised rowwise).
%   dbase [ struct ] Database with measurement variables.
%   range [ numeric ] Time range, i.e. <a href="dates.html">IRIS serial date numbers</a>.
% <a href="options.html">Optional input arguments:</a>
%   Check <a href="matlab: help MODEL/LOGLIK">help MODEL/LOGLIK</a> for other optional arguments.
%
% Nota bene:
%   <a href="matlab: help model/filte"r>MODEL/FILTER</a>, <a href="matlab: help model/loglik">MODEL/LOGLIK</a> (time domain) and <a href="matlab: help model/kalmanf">MODEL/KALMAN</a> differ only in their output arguments.
%
% The IRIS Toolbox 2007/09/04. Copyright 2007 Jaromir Benes. <a href="http://www.iris-toolbox.com">www.iris-toolbox.com</a>
%

[data,range,varargin,inputformat,userformat] = filterdata_(m,data,varargin{:});

% ###########################################################################################################
%% function body

[mloglik,se2,F,pe_,delta_,Pdelta,setup,pred,smooth] = loglikt_(m,data,range,[],varargin{:});

if ~isempty(delta_)
  if size(delta_,3) > length(m)
    % if loglikt_ called with single model but multiple data sets 
    % expand number of parameterisations
    m = nalter(m,size(delta_,3));
  end
  index = find(strcmp('outoflik',varargin));
  plist = varargin{index+1};
  if ischar(plist)
    plist = charlist2cellstr(plist);
  end
  % assign out-of-lik parameters
  for i = 1 : length(plist)
    index = strcmp(plist{i},m.name);
    m.assign(1,index,:) = delta_(1,i,:);
  end
  m = solve(m);
end

if se2 ~= 1
  m = stdscale(m,sqrt(se2));
end

% convert dpack to dbase
% no output format specified || dbase requested || auto requested and input format is dbase
if strcmpi(userformat,'dbase')  || (any(strcmpi(userformat,{'auto',''})) && strcmpi(inputformat,'dbase'))
  smooth.mean = dp2db(m,smooth.mean);
  smooth.std = dp2db(m,smooth.mse);
  smooth = rmfield(smooth,'mse');
end

% create database of out-of-lik parameter estimates
delta = struct();
if nargout > 3 && ~isempty(delta_)
  for i = 1 : length(plist)
    delta.(plist{i}) = vech(delta_(1,i,:));
  end
end

% create database of time series with prediction errors
if nargout > 4
  pe = struct();
  template = tseries();
  for i = find(m.nametype == 1)
    if m.log(i)
      pe_(i,:) = exp(pe_(i,:));
    end
    pe.(m.name{i}) = replace(template,vec(pe_(i,:)),range(1),m.name(i));
  end
end

if nargout > 5
  f = struct();
  template = tseries();
  for i = find(m.nametype == 1)
    f.(m.name{i}) = replace(template,vec(sqrt(F(i,i,:))),range(1),m.name(i));
  end
end

end
% end of primary function