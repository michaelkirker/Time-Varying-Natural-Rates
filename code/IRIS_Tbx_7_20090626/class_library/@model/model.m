function m = model(varargin)
% To get help for this IRIS function
% * type <a href="matlab: idoc model.model">idoc model.model</a>, or
% * open <a href="matlab: helpbrowser">Matlab Product Help</a> and go the The IRIS Toolbox at the bottom of the Contents pane,

% The IRIS Toolbox 2009/04/03.
% Copyright (c) 2007-2009 Jaromir Benes.

default = {
   'assign',struct(),@isstruct,...
   'baseyear',[],@(x) isnumeric(x) && length(x) <= 1,...
   'epsilon',eps^(1/3),@isnumericscalar,...
   'linear',[],@(x) (isnumeric(x) && isempty(x)) || islogical(x),...
   'precision','double',@(x) any(strcmp(x,{'double','single'})),...
   'std',NaN,@isnumericscalar,...
   'symbolic',true,@islogical,...
   'simplify',Inf,@isnumericscalar,...
   'torigin',2000,@isnumericscalar,...
};
options = passvalopt(default,varargin{2:end});

if ~isempty(options.baseyear)
   options.torigin = options.baseyear;
end

%********************************************************************
%! Function body.

if nargin == 0
   m = empty_();
   m = class(m,'model',contained());
   return
end

if nargin == 1 && ismodel(varargin{1})
   m = varargin{1};
   return
end

if nargin == 1 && isstruct(varargin{1})
   m = empty_();
   list = fieldnames(m);
   for i = 1 : length(list)
      try
         m.(list{i}) = varargin{1}.(list{i});
      end
   end
   m = class(m,'model',contained());
   return
end

if nargin > 0 && ischar(varargin{1})

   p = irisparser(varargin{1},options.assign);
   [m,options.assign] = p.model(empty_());
   m = class(m,'model',contained());
   
   % Linear or non-linear model.
   if ~isempty(options.linear)
      m.linear = options.linear;
   end
   
   % Differentiation step size.
   m.epsilon = options.epsilon;
   
   % Time origin (base year) for deterministic trends.
   if ~isempty(options.torigin)
      m.torigin = floor(options.torigin);
   end
   
   % Find recursive blocks.
   if ~m.linear
      m = reorder_(m);
   end
   
   % Creaete model-specific meta data.
   m = meta_(m);
   
   % Assign default stddevs.
   try
      defaultstd = assign.std_(1);
   catch
      if ~isnan(options.std)
         defaultstd = options.std;
      elseif m.linear
         defaultstd = 1;
      else
         defaultstd = 0.01;
      end
   end
   
   % Pre-allocate solution matrices etc.
   prealloc_();
   
   if ~isempty(options.assign) && isstruct(options.assign) && ~isempty(fieldnames(options.assign))
      m = assign(m,options.assign);
   end
   
   % Convert model equations to anonymous functions.
   m = eqtn2afcn_(m,options.symbolic && ~m.linear);
   
   % Pre-compute symbolic derivatives.
   if ~m.linear && options.symbolic && issymbolic()
      m = symbdiff(m,'simplify',options.simplify);
   end
   
   % Refresh dynamic links.
   if ~isempty(m.refresh)
      m = refresh(m);
   end
   
   return
end

error('Incorrect number or type of input argument(s).');

% End of function body.

%********************************************************************
%! Nested function empty_().

function m = empty_()
   m.fname = '';
   m.linear = false;
   if strcmpi(strtrim(options.precision),'single')
    m.precision = 'single';
   else
    m.precision = 'double';
   end
   m.assign = nan(0,m.precision);
   m.assign0 = nan(0,m.precision);
   
   m.name = {};
   m.namelabel = {};
   m.log = false([1,0]);
   [m.eqtn,m.eqtnS,m.eqtnF,m.eqtnlabel] = deal({});
   m.deqtnF = {};
   m.outside = [];
   m.mapoftunes = struct([]);
   m.nametype = zeros([1,0]);
   m.eqtntype = zeros([1,0]);
   m.occur = sparse(false([0,0]));
   m.tzero = NaN;
   m.refresh = [];
   
   m.nameorder = zeros([1,0]);
   m.eqtnorder = zeros([1,0]);
   
   m.systemid = {};
   m.metaderiv = struct();
   m.metasystem = struct();
   m.systemident = struct();
   m.metadelete = [];
   
   m.deriv0 = [];
   m.system0 = [];
   m.eigval = [];
   m.diffuse = {};
   m.optimal = false;
   m.epsilon = NaN;
   
   m.expand = {};
   m.solution(1:7) = {[]};
   m.solutionid = {{},{},{}};
   m.icondix = [];
   
   m.torigin = 2000;

end
% End of nested function empty_().

%********************************************************************
%! Nested function prealloc_().

function prealloc_()
   % Pre-allocate DERIV0 matrices.
   if issparse(m.occur)
    nt = size(m.occur,2)/length(m.name);
   else
    nt = size(m.occur,3);
   end
   nderiv = nt*sum(m.nametype <= 3);
   neqtn = sum(m.eqtntype <= 2);
   m.deriv0.c = zeros([neqtn,1]);
   m.deriv0.f = sparse(zeros([neqtn,nderiv]));
   
   % pre-allocate SYSTEM0 matrices
   ny = length(m.systemid{1});
   nx = length(m.systemid{2});
   ne = length(m.systemid{3});
   nf = sum(imag(m.systemid{2}) >= 0);
   nb = nx - nf;
   m.system0.K{1} = zeros([ny,1]);
   m.system0.K{2} = zeros([nx,1]);
   m.system0.A{1} = sparse(zeros([ny,ny]));
   m.system0.B{1} = sparse(zeros([ny,nb]));
   m.system0.E{1} = sparse(zeros([ny,ne]));
   m.system0.A{2} = sparse(zeros([nx,nx]));
   m.system0.B{2} = sparse(zeros([nx,nx]));
   m.system0.E{2} = sparse(zeros([nx,ne]));
   
   % Pre-allocate ASSIGN vectors.
   m.assign = nan([1,length(m.name)]);
   m.assign(m.nametype == 3) = 0;
   m.assign(end-sum(m.nametype == 3)+1:end) = defaultstd;
   m.assign0 = m.assign;
   
   % Pre-allocate SOLUTION and EXPAND matrices.
   ny = length(m.systemid{1});
   nx = length(m.systemid{2});
   nb = sum(imag(m.systemid{2}) < 0);
   nf = nx - nb;
   ne = length(m.systemid{3});
   fkeep = ~m.metadelete;
   nfkeep = sum(fkeep);
   m.solution{1} = nan([nfkeep+nb,nb],m.precision); % T
   m.solution{2} = nan([nfkeep+nb,ne],m.precision); % R
   m.solution{3} = nan([nfkeep+nb,1],m.precision); % K
   m.solution{4} = nan([ny,nb],m.precision); % Z
   m.solution{5} = nan([ny,ne],m.precision); % H
   m.solution{6} = nan([ny,1],m.precision); % D
   m.solution{7} = nan([nb,nb],m.precision); % U
   m.expand{1} = nan([nb,nf],m.precision);
   m.expand{2} = nan([nfkeep,nf],m.precision);
   m.expand{3} = nan([nf,ne],m.precision);
   m.expand{4} = nan([nf,nf],m.precision);
   m.expand{5} = nan([nf,nf],m.precision);
   
   % Preallocate EIGVAL and ICONDIX.
   m.eigval = nan([1,nx]);
   m.icondix = false([1,nb]);
end
% End of nested function prealloc_().

end
% End of primary function.
