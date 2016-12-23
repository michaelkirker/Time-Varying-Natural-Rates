function Y = resample(w,data,ndraw,varargin)
% <a href="matlab: edit VAR/resample">RESAMPLE</a>  Resample from VAR data.
%
% Syntax:
%   Y = resample(w,data,ndraw,...)
% Required input arguments:
%   Y [ tseries ] Resampled time series.
%   w [ VAR ] VAR to resample from.
%   data [ tseries ] Multivariate time series with VAR variables and residuals.
%   ndraw [ numeric ] Number of draws.
% <a href="options.html">Optional input arguments:</a>
%   'distribution' [ <a href="default.html">'bootstrap'</a> | 'normal' | function_handle ] Distribution to draw residuals and/or initial conditions from.
%   'randomise' [ true | <a href="default.html">false</a> ] Randomise initial conditions or use fixed pre-sample values.
%   'wild' [ true | <a href="default.html">false</a> ] Use wild bootstrap or standard Efron bootstrap.

% The IRIS Toolbox 2007/07/11.
% Copyright (c) 2007-2008 Jaromir Benes.

default = {
  'distribution','bootstrap',...
  'randomise',false,...
  'wild',false,...
};
options = passopt(default,varargin{:});

if ~istseries(data) || ~isnumeric(ndraw)
   error('Incorrect type of input argument(s).');
end

%********************************************************************
%! Function body .

[ny,p,nalt] = size(w);
[ans,ny2,ndata] = size(data);

if 2*ny ~= ny2
   error_(16);
end

% Works only with single parameterisation.
if nalt > 1
   error_(19,'RESAMPLE');
end

% Works only with single data set.
if ndata > 1
   error_(20,'RESAMPLE');
end

% Get input data including pre-sample.
[data,range] = rangedata(data,Inf);
data = transpose(data);
y = data(1:ny,:);
e = data(ny+(1:ny),:);

nper = length(range); % number of periods including initial condition
Y = nan([ny,nper,ndraw]);

% Fixed initial condtion from pre-sample data.
Y(:,1:p,:) = y(:,1:p,ones([1,ndraw]));

% TODO: randomise initial condition
%{
if options.randomise
else
end
%}

% Diagonlise RVAR residuals.
if isempty(w.B) && (strcmp(options.distribution,'normal') || isa(options.distribution,'function_handle'))
   Q = transpose(chol(w.Omega));
end

for idraw = 1 : ndraw
   E = zeros([ny,nper]);
   E(:,p+1:end) = drawresiduals_();
   if ~isempty(w.B)
      % SVAR.
      E(:,p+1:end) = w.B*E(:,p+1:end);
   end
   for t = p+1 : nper
      Y(:,t,idraw) = w.A*vec(Y(:,t-1:-1:t-p,idraw)) + E(:,t) + w.K;
   end
end

Y = tseries(range,permute(Y,[2,1,3]));

% End of function body.

%********************************************************************
%! Nested function drawresiduals_().

function E = drawresiduals_()
  if strcmp(options.distribution,'bootstrap')
    if options.wild
      % wild bootstrap
      % draw = ones([1,nper-p]) would reproduce sample
      draw = randn([1,nper-p]);
      E = e(:,p+1:end).*draw(ones([1,ny]),:);
    else
      % standard Efron bootstrap
      % draw = 1 : nper-p would reproduce sample
      % draw is uniform integer [1,nper-p]
      draw = 1 + floor((nper-p)*rand([1,nper-p]));
      E = e(:,p+draw);
    end
  elseif strcmp(options.distribution,'normal')
    E = randn([ny,nper-p]);
    if isempty(w.B)
      % RVAR.
      E = Q*E;
    end
  else
    if isempty(w.B)
      % RVAR.
      E = options.distribution([ny,nper-p],Omega);
    else
      % SVAR.
      E = options.distribution([ny,nper-p],eye(ny));
    end
  end
end
% End of nested function drawresiduals_().

end
% End of primary function.
