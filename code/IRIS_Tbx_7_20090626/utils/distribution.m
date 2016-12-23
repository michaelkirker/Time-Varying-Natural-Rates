function fcn = distribution(name,varargin)
%
% DISTRIBUTION  Create distribution function handle.
%
% Syntax:
%   fcn = distribution('beta',Lb,Ub,Ex,Std)
%   fcn = distribution('gamma',Lb,Ub,Ex,Std)
%   fcn = distribution('lognormal',Lb,Ub,Ex,Std)
%   fcn = distribution('normal',Lb,Ub,Ex,Std)
%   fcn = distribution('uniform',Lb,Ub)
%   fcn = distribution('pointmass',Lb,Ub,Ex)
%   fcn = distribution('empirical',Lb,Ub,Data)
%
% Syntax for calling fcn:
%    fx = fcn('pdf',x)
%    rnd = fcn('rnd',dim)
%    name = fcn('name')
%    xmean = fcn('mean')
%    xstd = fcn('std')
%    A = fcn('A') (available for Beta and Gamma only)
%    B = fcn('B') (available for Beta and Gamma only)
%    Mu = fcn('Mu') (available for Lognormal only)
%    Sigma = fcn('Sigma') (available for Lognormal only)
%    [rnd,index] = fcn('rnd',dim) (available for Empirical only)
%    rnd = fcn('draw',index) (available for Empirical only)
%    data = fcn('data') (available for Empirical only)
%
% The IRIS Toolbox 2007/05/03. Copyright 2007 Jaromir Benes. <a href="www.iris-toolbox.com">www.iris-toolbox.com</a>

% function body ---------------------------------------------------------------------------------------------

Lb = varargin{1}(1);
Ub = varargin{2}(1);

% point mass if std error = 0
if nargin > 4 && varargin{4} == 0, name = 'pointmass'; end

switch lower(strtrim(name))

case 'beta'
  if isinf(Lb) || isinf(Ub) || Lb >= Ub, error('Invalid bounds for beta distribution: [%g, %g].',Lb,Ub); end
  Ex = varargin{3};
  Std = varargin{4};
  if Std < 0, error('Standard error must be non-negative.'); end
  if Std > 0
    Ex_ = (Ex - Lb)/(Ub - Lb);
    Vx = (Std/(Ub - Lb)).^2;
    A = -Ex_*(Vx+Ex_.^2-Ex_)/Vx;
    B = (Vx+Ex_.^2-Ex_)/Vx*(Ex_-1);
  else
    A = NaN;
    B = NaN;
  end
  fcn = @beta;

case 'uniform'
  if isinf(Lb) || isinf(Ub) || Lb > Ub, error('Invalid bounds for uniform distribution: [%g, %g].',Lb,Ub); end
  Ex = (Ub + Lb) / 2;
  Vx = (Ub - Lb)^2 / 12;
  Std = sqrt(Vx);
  fcn = @uniform;

case 'gamma'
  if isinf(Lb) == isinf(Ub), error('Invalid bounds for gamma distribution: [%g, %g].',Lb,Ub); end
  if isinf(Lb), Lb = -Inf; else Ub = Inf; end
  Ex = varargin{3};
  Std = varargin{4};
  if Std < 0, error('Standard error must be non-negative.'); end
  if Std > 0
    if isinf(Ub), Ex = Ex - Lb;
      else Ex = -(Ex - Ub); end
    Vx = Std.^2;
    A = Ex.^2/Vx;
    B = Vx/Ex;
  else
    A = NaN;
    B = NaN;
  end
  fcn = @gamma;

case 'normal'
  if ~isinf(Lb) || ~isinf(Ub), error('Invalid bounds for lognormal distribution: [%g, %g].',Lb,Ub); end
  Ex = varargin{3};
  Std = varargin{4};
  if Std < 0, error('Standard error must be non-negative.'); end
  fcn = @normal;

case 'lognormal'
  if isinf(Lb) == isinf(Ub), error('Invalid bounds for lognormal distribution: [%g, %g].',Lb,Ub); end
  if isinf(Lb), Lb = -Inf; else Ub = Inf; end
  Ex = varargin{3};
  Std = varargin{4};
  if Std < 0, error('Standard error must be non-negative.'); end
  if Std > 0
    if isinf(Ub), Ex = Ex - Lb;
      else Ex = -(Ex - Ub); end
    Vx = Std^2;
    Mu = log(Ex^2/(Vx+Ex^2)^(1/2));
    Sigma = sqrt(2*log((Vx+Ex^2)^(1/2)/Ex));
  else
    Mu = NaN;
    Sigma = NaN;
  end
  fcn = @lognormal;

case 'pointmass'
  if Lb > Ub, error('Invalid bounds for point mass: [%g,%g].',Lb,Ub); end
  Ex = varargin{3};
  Std = 0;
  fcn = @pointmass;

case 'empirical'
  Data = vech(varargin{3});
  Ex = mean(Data);
  Std = std(Data,1);
  Max = max(Data);
  Min = min(Data);
  if isinf(Lb) ~= isinf(Ub) || Lb > Ub || Min < Lb || Max > Ub, error('Invalid bounds for empirical distribution: [%g, %g].',Lb,Ub); end
  Count = length(Data);
  fcn = @empirical;

otherwise
  error('Unrecognised distribution name: ''%s''.',name);

end

% end of function body --------------------------------------------------------------------------------------

  function output = beta(varargin) % nested function --------------------------------------------------------
  if isnumeric(varargin{1})
    x = varargin{1};
    x = (x - Lb)/(Ub - Lb);
    output = betapdf(x,A,B)/(Ub - Lb);
    return
  end
  action = varargin{1};
  varargin(1) = [];
  switch lower(strtrim(action))
  case 'pdf'
  case 'rnd'
    output = Lb + betarnd(A,B,varargin{1})*(Ub - Lb);
  case 'name'
    output = 'Beta';
  case {'a'}
    output = A;
  case {'b'}
    output = B;
  case {'lb','lbound'}
    output = Lb;
  case {'ub','ubound'}
    output = Ub;
  case {'ex','mean'}
    output = Ex;
  case 'std'
    output = Std;
  case 'isdistribution'
    output = true;
  otherwise
    output = [];
  end
  end % of nested function ----------------------------------------------------------------------------------

  function output = uniform(action,varargin) % nested function ----------------------------------------------
  switch lower(strtrim(action))
  case 'pdf'
    x = varargin{1};
    output = 1/(Ub - Lb)*ones(size(x));
  case 'rnd'
    output = unifrnd(Lb,Ub,varargin{1});
  case 'name'
    output = 'Uniform';
  case {'lb','lbound'}
    output = Lb;
  case {'ub','ubound'}
    output = Ub;
  case {'ex','mean'}
    output = Ex;
  case 'std'
    output = Std;
  case 'isdistribution'
    output = true;
  otherwise
    output = [];
  end
  end % of nested function ----------------------------------------------------------------------------------

  function output = gamma(action,varargin) % nested function ------------------------------------------------
  switch lower(strtrim(action))
  case 'pdf'
    x = varargin{1};
    if isinf(Ub), x = x - Lb;
      else x = -(x - Ub); end
    output = gampdf(x,A,B);
  case 'rnd'
    output = gamrnd(A,B,varargin{1});
    if isinf(Ub), output = output + Lb;
      else output = -output + Ub; end
  case 'name'
    output = 'Gamma';
  case {'a'}
    output = A;
  case {'b'}
    output = B;
  case {'lb','lbound'}
    output = Lb;
  case {'ub','ubound'}
    output = Ub;
  case {'ex','mean'}
    output = Ex;
  case 'std'
    output = Std;
  case 'isdistribution'
    output = true;
  otherwise
    output = [];
  end
  end % of nested function ----------------------------------------------------------------------------------

  function output = normal(action,varargin) % nested function -----------------------------------------------
  switch lower(strtrim(action))
  case 'pdf'
    x = varargin{1};
    output = normpdf(x,Ex,Std);
  case 'rnd'
    output = normrnd(Ex,Std,varargin{1});
  case 'name'
    output = 'Normal';
  case {'lb','lbound'}
    output = -Inf;
  case {'ub','ubound'}
    output = Inf;
  case {'ex','mean'}
    output = Ex;
  case 'std'
    output = Std;
  case 'isdistribution'
    output = true;
  otherwise
    output = [];
  end
  end % of nested function ----------------------------------------------------------------------------------

  function output = lognormal(action,varargin) % nested function --------------------------------------------
  switch lower(strtrim(action))
  case 'pdf'
    x = varargin{1};
    if isinf(Ub), x = x - Lb;
      else x = -(x - Ub); end
    output = lognpdf(x,Mu,Sigma);
  case 'rnd'
    output = lognrnd(Mu,Sigma,varargin{1});
    if isinf(Ub), output = output + Lb;
      else output = -output + Ub; end
  case 'name'
    output = 'Lognormal';
  case {'mu'}
    output = Mu;
  case {'sigma'}
    output = Sigma;
  case {'lb','lbound'}
    output = Lb;
  case {'ub','ubound'}
    output = Ub;
  case {'ex','mean'}
    output = Ex;
  case 'std'
    output = Std;
  case 'isdistribution'
    output = true;
  otherwise
    output = [];
  end
  end % of nested function ----------------------------------------------------------------------------------

  function output = pointmass(action,varargin) % nested function --------------------------------------------
  switch lower(strtrim(action))
  case 'pdf'
    x = varargin{1};
    output = 0;
    output(x == Ex) = Inf;
  case 'rnd'
    output = Ex*ones(varargin{1});
  case 'name'
    output = 'Pointmass';
  case {'lb','lbound'}
    output = Lb;
  case {'ub','ubound'}
    output = Ub;
  case {'ex','mean'}
    output = Ex;
  case 'std'
    output = 0;
  case 'isdistribution'
    output = true;
  otherwise
    output = [];
  end
  end % of nested function ----------------------------------------------------------------------------------

  function [output,index] = empirical(action,varargin) % nested function ------------------------------------
  switch lower(strtrim(action))
  case 'pdf'
    x = varargin{1};
    output = zeros(size(x));
    index = x > Lb & x < Ub;
    if isinf(Lb) && isinf(Ub), output(index) = ksdensity(Data,x(index));
      else output(index) = ksdensity(Data,x(index),'support',[Lb,Ub]); end
  case 'rnd'
    index = ceil(Count.*rand(varargin{1}));
    output = Data(index);
  case {'draw','draws'}
    output = Data(varargin{1});
  case 'name'
    output = 'Empirical';
  case {'lb','lbound'}
    output = Lb;
  case {'ub','ubound'}
    output = Ub;
  case {'n','count'}
    output = Count;
  case {'sigma'}
    output = Sigma;
  case {'min'}
    output = Min;
  case {'max'}
    output = Max;
  case {'ex','mean'}
    output = Ex;
  case 'std'
    output = Std;
  case 'data'
    output = Data;
  case 'isdistribution'
    output = true;
  otherwise
    output = [];
  end
  end % of nested function ----------------------------------------------------------------------------------

end % of primary function -----------------------------------------------------------------------------------