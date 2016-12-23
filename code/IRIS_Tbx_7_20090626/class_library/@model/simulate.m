function [data,varargout] = simulate(m,data,varargin)
% To get help for this IRIS function
% * type <a href="matlab: idoc model.simulate">idoc model.simulate</a>, or
% * open <a href="matlab: helpbrowser">Matlab Product Help</a> and browse the The IRIS Toolbox documentation found in the Contents pane.

% The IRIS Toolbox 2009/01/27.
% Copyright 2007-2009 Jaromir Benes.

% Distinguish between input dbase and dpack.
inputformat = dataformat(data);
if strcmpi(inputformat,'dbase')
   range = varargin{1};
   varargin(1) = [];
else
   range = datarequest('range',m,data);
end

if ~any(strcmpi(inputformat,{'dbase','dpack'})) ...
   || ~isnumeric(range) ...
   || ~iscellstr(varargin(1:2:end))
   
   error('Incorrect type of input argument(s).');
end

default = {...
   'anticipate',true,@islogical,...
   'checkonly',false,@(x) islogical(x) && length(x) == 1,...
   'contributions',false,@(x) islogical(x) && length(x) == 1,...
   'deviation',false,@islogical,...
   'dtrends','auto',@(x) islogical(x) || strcmpi(x,'auto'),...
   'output','auto',@(x) any(strcmpi(x,{'auto','dbase','dpack'})),...
   'ignoreresiduals',false,@islogical,...
   'plan',[],@(x) isempty(x) || isa(x,'plan') || isstruct(x),...
   'nonlinper',0,@(x) ~isempty(x) && isnumeric(x),...
   'nonlineqtn',{},@(x) ischar(x) || iscellstr(x),...
   'nonlintol',1e-5,@isnumeric,...
   'nonlinmaxiter',100,@isnumeric,...
   'nonlindisplay',true,@islogical,...
   'nonlinlambda',1,@(x) isnumeric(x) && length(x) == 1 && x > 0 && x <= 1,...
};
options = passvalopt(default,varargin{:});

if ischar(options.dtrends)
   options.dtrends = ~options.deviation;
end

% Determine output data format.
if strncmpi(options.output,'a',1)
   options.output = inputformat;
end

%********************************************************************
%! Function body.

[ny,nx,nf,nb,ne,np,nalt] = size_(m);
range = range(1) : range(end);
nper = length(range);
realsmall = getrealsmall();

nanticipate = length(options.anticipate(:));
nignore = length(options.ignoreresiduals(:));
nnonlinper = length(options.nonlinper);

% Get init cond for alpha.
% alpha is always expanded to match nalt.
[init,naninit] = datarequest('init',m,data,range);
if ~isempty(naninit) && ~options.checkonly
   naninit = unique(naninit);
   error_(25,naninit);
end
ninit = size(init,3);

% Get y, current dates for [xf;xb], and e.
% Vector xb is not transformed.
data = {...
   datarequest('y',m,data,range),...
   datarequest('x0',m,data,range),...
   datarequest('e',m,data,range),...
};
ndata = size(data{2},3);

% Fix the 3rd dimension for measurement vars and shocks.
% This is when there are none of them,
% because |datarequest| returns 0 x nper matrices.
if size(data{1},3) < ndata
   data{1} = cat(3,data{1},data{1}(:,:,end*ones([1,ndata-size(data{1},3)])));
end
if size(data{3},3) < ndata
   data{3} = cat(3,data{3},data{3}(:,:,end*ones([1,ndata-size(data{3},3)])));
end

% [init,data,naninit] = simuldata_(m,data,range);
nloop = max([nalt,ninit,ndata,nanticipate,nignore,nnonlinper]);

% Expand init in 3rd dim to match nloop.
if ninit < nloop
   init = init(:,1,[1:end,end*ones([1,nloop-ndata])]);
end

% Expand data in 3rd dim to match nloop.
if ndata < nloop
   for i = 1 : 3
      data{i} = data{i}(:,:,[1:end,end*ones([1,nloop-ndata])]);
   end
end

% Find endogenised/exogenised data points.
% Create datapack with anchors.
if isplan(options.plan)
   options.plan = plan2dbase(options.plan);
end
if ~isempty(options.plan) && (isstruct(options.plan) || iscell(options.plan))
   % Request y* and x0* so that plan values are not logarithmised.
   anchors = {...
      datarequest('y*',m,options.plan,range),...
      datarequest('x0*',m,options.plan,range),...
      datarequest('e',m,options.plan,range),...
   };
else
   anchors = {...
      false([ny,nper]),...
      false([nx,nper]),...
      false([ne,nper]),...
   };
end

% Convert anchors to logicals.
% Treat NaN as false.
for i = 1 : 3
   anchors{i}(isnan(anchors{i})) = 0;
   anchors{i} = logical(anchors{i});
end

% No anchors if there is no exogenised or endogenised data point
if ~any(any([anchors{1};anchors{2}])) || ~any(any(anchors{3}))
   anchors{1}(:) = false;
   anchors{2}(:) = false;
   anchors{3}(:) = false;
end

% Fast conditional simulation if unanticipated
% and = exogenised points == = endogenised points at each t
if any(~options.anticipate) && all(sum([anchors{1};anchors{2}],1) == sum(anchors{3},1))
	fast = ~options.anticipate;
else
   fast = false(size(options.anticipate));
end

% Check source data for NaN exogenised data points.
nanexog = chkexog_();
if ~options.checkonly && ~isempty(nanexog)
  error_(26,nanexog);
end

% Stop here if check only requested.
if options.checkonly
   data = isempty(naninit) && isempty(nanexog);
   varargout{1} = naninit;
   varargout{2} = nanexog;
   return
end

% Incompatible options for contributions simulation.
if options.contributions
   if ~isempty(options.plan)
      error_(51,'CONTRIBUTIONS PLAN');
   end
   if nalt > 1
      error_(47,'SIMULATE');
   end
   % Expand data in 3rd dimension; will be filled with ne+1 contributions.
   for i = 1 : 3
      data{i} = data{i}(:,:,ones([1,ne+1]));
   end
end

% Find position of last logical true, or return zero.
lastOrZero_ = @(x) max([0,find(any(x,1),1,'last')]);

% Index of NaN solutions.
[flag,nansolution] = isnan(m,'solution');
% Index of NaN expansions.
[void,nanexpansion] = isnan(m,'expansion');
% List of expansions not available, reported at the end.
cannotExpand = [];

%********************************************************************
%! Main loop.

use = struct();
for iloop = 1 : nloop

   % Refresh anchors, because anchors get re-written in nonlin simulations.
   use.anchors = anchors;
   % Position of last endogenised residual.
   lastendog = lastOrZero_(use.anchors{3});
   % Position of last exogenised data point.
   lastexog = lastOrZero_([use.anchors{1};use.anchors{2}]);

   if iloop <= nanticipate
      use.anticipate = options.anticipate(iloop);
      use.fast = fast(iloop);
   end
   
   if iloop <= nignore
      use.ignoreresiduals = options.ignoreresiduals(iloop);
   end
   
   if iloop <= nnonlinper 
      use.nonlinper = options.nonlinper(iloop);
   end
   
   if iloop <= nalt
      T = m.solution{1}(:,:,iloop);
      R = m.solution{2}(:,:,iloop);
      K = m.solution{3}(:,:,iloop);
      Z = m.solution{4}(:,:,iloop);
      H = m.solution{5}(:,:,iloop);
      D = m.solution{6}(:,:,iloop);
      U = m.solution{7}(:,:,iloop);
      for i = 1 : length(m.expand)
         use.expand{i} = m.expand{i}(:,:,iloop);
      end
      % Compute deterministic trends if requested.
      if options.dtrends
         [ans,ans,W] = dtrends_(m,range,iloop);
      end
      use.nanexpansion = nanexpansion(iloop);
      use.nansolution = nansolution(iloop);
   end

   % Nonlinear simulations.
   if use.nonlinper > 0 && ~isempty(options.nonlineqtn)
      [use.nonlineqtn,use.nonlinxi,use.nonlinei] = nonlinfnhandle_(m,options.nonlineqtn);
      if options.deviation
         use.nonlinxbar = trendarray_(m,m.solutionid{2},0:use.nonlinper,false,min([iloop,nalt]));
      end
   else
      use.nonlineqtn = {};
      use.nonlinxi = [];
      use.nonlinei = [];
   end

   % Where to place results in data{}.
   % Contributions simulation produces ne+1 pages.
   if options.contributions
      placeInData = 1 : ne+1;
   else
      placeInData = iloop;
   end
   
   % Solution not available.
   if use.nansolution
      data{1}(:,:,placeInData) = NaN;
      data{2}(:,:,placeInData) = NaN;
      continue
   end

   % Initial condition.
	a0 = init(:,1,iloop);
   
   % Get residuals,
   % and position of last anticipated residual.
   if use.ignoreresiduals
      e = zeros([ne,nper]);
   else
      e = data{3}(:,:,iloop);
   end
       
   % Tunes on measurement variables.
   ytune = data{1}(:,:,iloop);
   if options.dtrends
      ytune = ytune - W;
   end
   
   % Tunes on transition variables.
   xtune = data{2}(:,:,iloop);
   
   nonlinwhile = true;
   nonlincount = 0;
   MX = [];
   MY = [];
   while nonlinwhile

   if use.anticipate
      use.lastResidA = lastOrZero_(real(e) ~= 0);
   else
      use.lastResidA = lastOrZero_(imag(e) ~= 0);
   end

   % Expand solution forward.
   if ne > 0
      % Current expansion is to t+k0.
      k0 = size(R,2)/ne - 1;
      % Expansion needed to t+k.
      k = max([1,use.lastResidA,lastendog]) - 1;
      % Expand solution forward to t+k.
      if k > k0
         if use.nanexpansion
            % Expansion not available, throw a warning at the end.
            cannotExpand(end+1) = iloop;
            data{1}(:,:,placeInData) = NaN;
            data{2}(:,:,placeInData) = NaN;
            continue
         end        
         R = expand_(R,k,use.expand{1:5});
      end
   end
   
   if lastexog > 0
      if use.fast
         % Fast exogenised simulation.
         % Mutlipliers are computed inside |simulatemean|.
         f = struct();
         f.anchors = use.anchors;
         f.ytune = ytune;
         f.xtune = xtune;
         [y,w,e] = time_domain.simulatemean(...
            T,R,K,Z,H,D,U,...
            a0,e,nper,use.anticipate,options.deviation,f);
      else
         % Slow exogenised simulation.
         % Plain simulation first.
         [y,w] = time_domain.simulatemean(...
            T,R,K,Z,H,D,U,...
            a0,e,lastexog,use.anticipate,options.deviation,[]);
         % Compute multiplier matrices.
         if size(MX,1) < nx*lastexog || size(MX,2) < ne*lastendog
            [MY,MX] = impact_();
         end
         % Back out residuals.
         adde = exogenise_();
         index = find(adde ~= 0);
         % Add residuals.
         e(index) = e(index) + adde(index);
         % Re-simulate with residuals added.
         [y,w] = time_domain.simulatemean(...
            T,R,K,Z,H,D,U,...
            a0,e,nper,use.anticipate,options.deviation,[]);
      end
   else
      if ~options.contributions
         % Plain simulation.
         [y,w] = time_domain.simulatemean(...
            T,R,K,Z,H,D,U,...
            a0,e,nper,use.anticipate,options.deviation,[]);
      else
         % Compute contributions of shocks and init.cond.+constant
         e0 = e;
         e = zeros([size(e0),ne+1]);
         y = nan([ny,nper,ne+1]);
         w = nan([nx,nper,ne+1]); % := [xf;a]
         for i = 1 : ne
            e(i,:,i) = e0(i,:);
            [y(:,:,i),w(:,:,i)] = time_domain.simulatemean(...
               T,R,K,Z,H,D,U,...
               zeros(size(a0)),e(:,:,i),nper,use.anticipate,true,[]);
         end
         [y(:,:,ne+1),w(:,:,ne+1)] = time_domain.simulatemean(...
            T,R,K,Z,H,D,U,...
            a0,e(:,:,ne+1),nper,use.anticipate,options.deviation,[]);
      end
   end

   % Non-linear simulations.
   if use.nonlinper > 0 && ~isempty(use.nonlineqtn)
      nonlin_();
   else
      nonlinwhile = false;
   end
   
   end % of nonlinear while.
   
   % Add measurement detereministic trends.
   if options.dtrends
      % Add to simulation.
      % When contributions == true, add to last simulation.
      y(:,:,end) = y(:,:,end) + W;
   end
   
   % Store results.
   data{1}(:,:,placeInData) = y;
   data{2}(:,:,placeInData) = w;
   data{3}(:,:,placeInData) = e;
  
end
% End of main loop.

%********************************************************************
%! Post-mortem.

% Add initial conditions to datapack.
if options.contributions
   tmpinit = zeros([size(init),ne+1]);
   tmpinit(:,1,end) = init;
   data{1} = [nan([ny,1,ne+1],m.precision),data{1}];
   data{2} = [[nan([nf,1,ne+1],m.precision);tmpinit],data{2}];
   data{3} = [nan([ne,1,ne+1],m.precision),data{3}];
else
   data{1} = [nan([ny,1,nloop],m.precision),data{1}];
   data{2} = [[nan([nf,1,nloop],m.precision);init],data{2}];
   data{3} = [nan([ne,1,nloop],m.precision),data{3}];
end
data{4} = [range(1)-1,range];

% Add meta information to datapack.
data{5} = meta(m,false);

if strcmp(options.output,'dbase')
   data = dp2db(m,data);
   % Add shock names to contributions simulation.
   if options.contributions
      aux = [m.name(m.nametype == 3),{'Init cond + const'}];
      for i = find(m.nametype <= 3)
         data.(m.name{i}) = comment(data.(m.name{i}),aux);
      end    
   end
end

% Solution not available.
if flag
   warning_(44,sprintf(' #%g',find(nansolution)));
end

% Expansion not available.
if ~isempty(cannotExpand)
   warning_(45,sprintf(' #%g',cannotExpand));
end

% End of function body.

%********************************************************************
%! Nested function chkexog_().
   function nanexog = chkexog_()
      % check for NaN exogenised data points
      nanexog = {};
      index = any([anchors{1};anchors{2}] & [any(isnan(data{1}),3);any(isnan(data{2}),3)],2);
      if any(index)
         id = [m.solutionid{1:2}];
         nanexog = unique(m.name(real(id(index))));
      end
   end  
% End of nested function chkexog_().

%********************************************************************
%! Nested function impact_().
   function [MY,MX] = impact_()
     MY = zeros([ny*lastexog,ne*lastendog]);
     MX = zeros([nx*lastexog,ne*lastendog]);
     if use.anticipate
       RR = R(:,1:ne*lastendog);
       MX(1:nx,:) = RR;
     else
       RR = R(:,1:ne);
       MX(1:nx,1:ne) = RR;
     end
     for t = 2 : lastexog
       nonzero = find(any(MX((t-2)*nx+(1:nx),:),1));
       MX((t-1)*nx+(1:nx),nonzero) = T*MX((t-2)*nx+(nf+1:nx),nonzero);
       if use.anticipate
         RR = RR(:,1:end-ne);
         MX((t-1)*nx+(1:nx),(t-1)*ne+1:end) = MX((t-1)*nx+(1:nx),(t-1)*ne+1:end) + RR;
       elseif t <= lastendog
         MX((t-1)*nx+(1:nx),(t-1)*ne+(1:ne)) = MX((t-1)*nx+(1:nx),(t-1)*ne+(1:ne)) + RR;
       end
     end
     for t = 1 : lastexog
       MY((t-1)*ny+(1:ny),:) = Z*MX((t-1)*nx+(nf+1:nx),:);
       MY((t-1)*ny+(1:ny),(t-1)*ne+(1:ne)) = MY((t-1)*ny+(1:ny),(t-1)*ne+(1:ne)) + H;
       nonzero = find(any(MX((t-1)*nx+(nf+1:nx),:),1));
       MX((t-1)*nx+(nf+1:nx),nonzero) = U*MX((t-1)*nx+(nf+1:nx),nonzero);
     end
   end
% End of nested function impact_().

%********************************************************************
%! Nested function exogenise_().
   function adde = exogenise_()
      yindex = vec(use.anchors{1}(:,1:lastexog));
      xindex = vec(use.anchors{2}(:,1:lastexog));
      eindex = vec(use.anchors{3}(:,1:lastendog));
      % Convert [xf;a] vector to [xf;xb] vector.
      x = w;
      x(nf+1:end,:) = U*x(nf+1:end,:);
      % Compute prediction errors.
      ype = [];
      xpe = [];
      for t = 1 : lastexog
         ype = [ype;ytune(use.anchors{1}(:,t),t)-y(use.anchors{1}(:,t),t)];
         xpe = [xpe;xtune(use.anchors{2}(:,t),t)-x(use.anchors{2}(:,t),t)];
      end
      M = [MY(yindex,eindex);MX(xindex,eindex)];
      adde = zeros([ne,lastendog],m.precision);
      adde(eindex) = M \ [ype;xpe];
   end
% End of nested function exogenise_().

%********************************************************************
%! Nested function nonlin_().
   function nonlin_()
      tmpt = 1 : use.nonlinper;
      tmpx = [[nan([nf,1]);a0],w(:,tmpt)];
      tmpx(nf+1:end,:) = U*tmpx(nf+1:end,:);
      xactual = tmpx(use.nonlinxi,1+tmpt);
      if options.deviation
         tmpx = tmpx + use.nonlinxbar;
      end
      tmpe = [zeros([ne,1]),e(:,tmpt)];
      tmpe(use.nonlinei,:) = 0;
      tmpp = m.assign(1,m.nametype == 4,1);
      nnonlineqtn = length(use.nonlineqtn);
      xtarget = zeros([nnonlineqtn,use.nonlinper]);
      for i = 1 : nnonlineqtn
         xtarget(i,:) = use.nonlineqtn{i}(tmpx,tmpe,tmpp,1+tmpt);
      end
      if options.deviation
         xtarget = xtarget - use.nonlinxbar(use.nonlinxi,1+tmpt);
      end
      % Maximum discrepancy.
      discrep = abs(xactual - xtarget);      
      maxdiscrep2 = max(discrep,[],2);
      maxdiscrep = max(maxdiscrep2);
      maxdiscrepeqtn = findnaninf(maxdiscrep2,maxdiscrep,1,'first');
      maxaddfactor2 = max(abs(e(use.nonlinei,tmpt)),[],2);
      maxaddfactor = max(maxaddfactor2);
      maxaddfactoreqtn = findnaninf(maxaddfactor2,maxaddfactor,1,'first');
      use.anchors{2}(use.nonlinxi,tmpt) = true;
      use.anchors{3}(use.nonlinei,tmpt) = true;
      lastendog = lastOrZero_(use.anchors{3});
      lastexog = lastOrZero_([use.anchors{1};use.anchors{2}]);
      xtune(use.nonlinxi,tmpt) = options.nonlinlambda*xtarget + (1-options.nonlinlambda)*xactual;
      nonlincount = nonlincount + 1;
      nonlinwhile = ...
         all(maxdiscrep(:) > options.nonlintol(:)) ...
         && nonlincount <= options.nonlinmaxiter;
      % Report this iteration if requested.
      if options.nonlindisplay
         nonlinreport_(...
            nonlincount,maxdiscrep,maxaddfactor,...
            options.nonlineqtn{maxdiscrepeqtn},...
            options.nonlineqtn{maxaddfactoreqtn},...
            nonlinwhile);
      end
   end  
% End of nested function chkexog_().


end
% End of primary function.

%********************************************************************
% Subfunction nonlinreport_().
% Report nonlin simulation iteration.
function nonlinreport_(nonlincount,maxdiscrep,maxaddfactor,...
   maxdiscrepeqtn,maxaddfactoreqtn,nonlinwhile)
   if nonlincount == 1
      fprintf('\tIter\t Max discrep\tEqtn\t\t\t  Max add-factor\tEqtn\n');
   end         
   fprintf(...
      '\t%g\t\t%12g\t%s\t%12g\t%s\n',...
      nonlincount,maxdiscrep,padlabel_(maxdiscrepeqtn,16),...
      maxaddfactor,padlabel_(maxaddfactoreqtn,16));
   if ~nonlinwhile
      fprintf('\n');
   end
end
% End of subfunction nonlinreport_().

%********************************************************************
% Subfunction padlabel_().
% Cut eqtn labels or add padding spaces to eqtn labels.
function label = padlabel_(label,n)
   nlabel = length(label);
   if nlabel > n-3
      label = [label(1:n-3),'...'];
   else
      label = [label,char(32*ones([1,n-nlabel]))];
   end
end
% End of subfunction padlabel_().