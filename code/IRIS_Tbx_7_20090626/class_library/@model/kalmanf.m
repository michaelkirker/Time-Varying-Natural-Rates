function [mloglik,se2,pred,smooth] = kalmanf(this,data,varargin)
% <a href="matlab: edit model/kalmanf">KALMANF</a>  Kalman filter.
%
% Syntax:
%   [mloglik,se2,pred,smooth] = kalmanf(this,dpack,...)
%   [mloglik,se2,pred,smooth] = kalmanf(this,dbase,range,...)
% Output arguments:
%   mloglik [ numeric ] Minus log-likelihood.
%   se2 [ numeric ] Estimated common variance factor (if option 'relative' is true).
%   pred [ cell | struct ] Datapack or database (depending on 'output' option) with Kalman prediction (mean).
%   smooth [ cell | struct ] Datapack or database (depending on 'output' option) with Kalman smoother (mean).
% Required input arguments:
%   this [ model ] Model.
%   dpack [ cell | numeric ] Input datapack or data array.
%   dbase [ cell | numeric ] Input database.
%   range [ numeric ] Time range, i.e. <a href="dates.html">IRIS serial date numbers</a>.
% <a href="options.html">Optional input arguments:</a>
%   'output' [ <a href="default.html">'auto'</a> | 'dbase' | 'dpack' ] Output data format.
%   Check <a href="matlab: help MODEL/LOGLIK">help MODEL/LOGLIK</a> (time-domain) for other optional arguments.
%
% Nota bene:
%   <a href="matlab: help model/filte"r>MODEL/FILTER</a>, <a href="matlab: help model/loglik">MODEL/LOGLIK</a> (time domain) and <a href="matlab: help model/kalmanf">MODEL/KALMAN</a> differ only in their output arguments.

% The IRIS Toolbox 2009/04/28.
% Copyright 2007-2009 Jaromir Benes.

warning('iris:obsolete','KALMANF is deprecated syntax, and will not be supported in future versions of IRIS. Use FILTER instead.');

% Get array of measurement variables.
[data,range,varargin,outputformat] = loglikdata_(this,data,varargin{:});
options = logliktopt_(this,range,'t',varargin{:});

%********************************************************************
%! Function body.

% Call Kalman filter.
[mloglik,se2,F,pe,A,ans,ans,pred,smooth] = loglikt2_(this,data,range,[],options);

% Dump inverses of FMSE matrices.
F = F{1};

% Convert dpack to dbase if requested.
if strcmpi(outputformat,'dbase')
   pred = dp2db(this,pred.mean);
   smooth = dp2db(this,smooth.mean);
end

end
% End of primary function.