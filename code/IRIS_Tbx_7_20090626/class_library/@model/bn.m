function [data,cums] = bn(this,data,varargin)
% To get help for this IRIS function
% * type <a href="matlab: idoc model.bn">idoc model.bn</a>, or
% * open <a href="matlab: helpbrowser">Matlab Product Help</a> and go the The IRIS Toolbox at the bottom of the Contents pane,

% The IRIS Toolbox 2009/05/20.
% Copyright (c) 2007-2008 Jaromir Benes.

if ~isstruct(data) && ~iscell(data)
   error('Incorrect type of input arguments.');
end

% Convert database to datapack if needed.
if isstruct(data)
   range = varargin{1}(1):varargin{1}(end);
   varargin(1) = [];
   data = db2dp(this,data,range);
end

default = {...
  'deviation',false,@islogical,...
  'output','dbase',@(x) any(strcmp(x,{'dbase','dpack'})),...
};
options = passvalopt(default,varargin{:});

%********************************************************************
%! Function body.

% remove pre-sample initial condition from datapack
for i = 1 : 4
   data{i} = data{i}(:,2:end,:);
end

tol = getrealsmall();
[ny,nx,nf,nb,ne,np,nalt] = size_(this);
nunit = sum(abs(abs(this.eigval) - 1) <= tol);
input = data{2};
[ans,nper,ninput] = size(input);

[flag,nans] = isnan(this,'solution');
% solution not available for some parameterisations
if flag
  warning_(44,sprintf(' #%g',find(nans)));
end

nloop = max([ninput,nalt]);

% re-use input datapack for output datapack
% expand output datapack if needed
% data to contain beveridge nelson permanent components
% cums to contain cum sum of deviations of stationary variables
if ninput < nloop
  repeat = ones([1,nloop-ninput]);
  for i = 1 : 3
    data{i} = data{i}(:,:,[1:end,end*repeat]);
  end
end
cums = data;

for iloop = 1 : nloop

  % assign model matrices and compute steady state for current parameterisation
  if iloop <= nalt
    Tfi = this.solution{1}(1:nf,:,iloop);
    Tai = this.solution{1}(nf+1:end,:,iloop);
    Zi = this.solution{4}(:,:,iloop);
    Ui = this.solution{7}(:,:,iloop);
    nansi = nans(iloop);
    % non-stationary xf and y
    xfdiffuse = any(abs(Tfi(:,1:nunit)) > tol,2);
    ydiffuse = any(abs(Zi(:,1:nunit)) > tol,2);
    % steady state for [xf;alpha]
    if ~options.deviation
      Kfi = this.solution{3}(1:nf,1,iloop);
      Kai = this.solution{3}(nf+1:end,1,iloop);
      abar = zeros([nb,1]);
      abar(nunit+1:end) = (eye(nb-nunit) - Tai(nunit+1:end,nunit+1:end)) \ Kai(nunit+1:end);
      xfbar = Tfi(:,nunit+1:end)*abar(nunit+1:end) + Kfi;
      abar = abar(:,ones([1,nper]));
      xfbar = xfbar(:,ones([1,nper]));
    end
  end
  if nansi
    continue
  end
  if iloop <= ninput
    inputi = input(:,:,iloop);
    % subtract steady state from [xf;alpha]
    if ~options.deviation
      inputi = inputi - [xfbar;abar];
    end
  end
  a = zeros([nb,nper]);

%********************************************************************
% Cum sum for stationary variables.

  a(nunit+1:end,:) = (eye(nb-nunit) - Tai(nunit+1:end,nunit+1:end)) \ inputi(nf+nunit+1:end,:);
  xf = inputi(1:nf,:) + Tfi(:,nunit+1:end)*a(nunit+1:end,:);
  y = Zi(:,nunit+1:end)*a(nunit+1:end,:);
  xf(xfdiffuse,:) = 0;
  y(ydiffuse,:) = 0;
  % use input datapack as output datapack
  cums{1}(:,:,iloop) = y;
  cums{2}(:,:,iloop) = [xf;a];
  % residual variables remain unchanged

%********************************************************************
% Beveridge Nelson for non-stationary variables.

  a(1:nunit,:) = inputi(nf+1:nf+nunit,:) + Tai(1:nunit,nunit+1:end)*a(nunit+1:end,:);
  if options.deviation
    a(nunit+1:end,:) = 0;
  else
    a(nunit+1:end,:) = abar(nunit+1:end,:);
  end
  xf = Tfi(:,1:nunit)*a(1:nunit,:);
  y = Zi(:,1:nunit)*a(1:nunit,:);
  data{1}(:,:,iloop) = y;
  data{2}(:,:,iloop) = [xf;a];
  data{3}(:,:,iloop) = 0;

end

%********************************************************************
% Backmatter.

% Datapack assumed to contain pre-sample initial conditions.
data{1} = [nan([ny,1,nloop]),data{1}];
data{2} = [nan([nx,1,nloop]),data{2}];
data{3} = [nan([ne,1,nloop]),data{3}];
data{4} = [data{4}(1)-1,data{4}];
cums{1} = [nan([ny,1,nloop]),cums{1}];
cums{2} = [nan([nx,1,nloop]),cums{2}];
cums{3} = [nan([ne,1,nloop]),cums{3}];
cums{4} = [cums{4}(1)-1,cums{4}];

if strcmp(options.output,'dbase')
  data = dp2db(this,data,'include',false);
  cums = dp2db(this,cums,'include',false);
end

end
% End of primary function.