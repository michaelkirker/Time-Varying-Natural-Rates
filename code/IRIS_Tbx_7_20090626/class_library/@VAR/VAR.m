function [this,varargout] = VAR(varargin)
% <a href="matlab: edit VAR/VAR">VAR</a>  Estimate reduced-form VAR model.
%
% Syntax:
%    [this,data,Rr] = VAR(y,...)
%    [this,data,Rr] = VAR(x,range,...)
%    [this,data,Rr] = VAR(d,list,range,...)
% Output arguments:
%    this [ VAR ] Estimated reduced-form VAR model.
%    data [ tseries ] Multivariate time series with VAR variables and residuals.
%    Rr [ numeric ] Linear constraints in matrix form: beta=r+R*gamma, Rr = [R,r].
% Required input arguments for syntax
%    y [ numeric ] Input data including initial condition.
%    x [ tseries ] Input data.
%    range [ numeric ] Time range to be explained (not to include dates used as initial condition).
%    d [ struct ] Input database.
%    list [ cellstr | char ] List of time series.
% <a href="options.html">Optional input arguments:</a>
%    'order' [ numeric | <a href="default.html">1</a> ] Order of VAR.
%    'cointeg' [ numeric | <a href="default.html">empty</a> ] Matrix of conintegrating vectors.
%    'constraint' [ char | numeric | <a href="default.html">empty</a> ] Linear constraints on parameters in character string or matrix form.
%    'comment' [ anything | <a href="default.html">empty</a> ] User comments.
%    'constant' [ <a href="default.html">true</a> | false ] Include constant.
%    'maxiter' [ numeric | <a href="default.html">10</a> ] Maximum number of iteration for GLS.
%    'mean' [ numeric | <a href="default.html">empty</a> ] Imposed mean of VAR process.
%    'tolerance' [ numeric | <a href="default.html">1e-5</a> ] Tolerance criterion for GLS.

% The IRIS Toolbox 2008/09/25.
% Copyright (c) 2007-2008 Jaromir Benes.

%********************************************************************
%! Function body.

if nargin == 0
   % Empty object.
   this = empty_();
   this = class(this,'VAR',contained());

elseif nargin == 1 && isvar(varargin{1})
   % VAR in, VAR out.
   this = varargin{1};

elseif nargin == 1 && isstruct(varargin{1})
   % Called from within load(), loadobj(), loadstruct().
   this = empty_();
   list = fieldnames(this);
   for i = 1 : length(list)
      try
         this.(list{i}) = varargin{1}.(list{i});
      end
   end
   this = class(this,'VAR',contained());

elseif nargin >= 1
   % Estimate rVAR.
   this = empty_();
   this = class(this,'VAR',contained());
   [this,varargout{1:nargout-1}] = estimate_(this,varargin{:});
end

end
% End of primary function.

%********************************************************************
%! Subfunction empty_(). 

function this = empty_() 

% Fields for reduced-form and structural VARs.
this.IRIS_VAR = true;
this.A = [];
this.K = [];
this.Omega = []; % Cov of residuals
this.Sigma = []; % Cov of parameters
this.T = [];
this.U = [];
this.sample = [];
this.aic = NaN;
this.sbc = NaN;
this.Rr = [];
this.nhyper = NaN;
this.eigval = [];
this.comment = '';

% Fileds only for structural VARs.
this.B = [];
this.std = [];

end
% End of subfunction empty_().
