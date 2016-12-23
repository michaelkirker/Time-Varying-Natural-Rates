function varargout = get(this,varargin)
% To get help for this IRIS function
% * type <a href="matlab: idoc model.get">idoc model.get</a>, or
% * open <a href="matlab: helpbrowser">Matlab Product Help</a> and go the The IRIS Toolbox at the bottom of the Contents pane,

% The IRIS Toolbox 2009/02/18.
% Copyright (c) 2007-2009 Jaromir Benes.

[ny,nx,nf,nb,ne,np,nalt] = size_(this);

%********************************************************************
%! Function body.

loglin = this.log;

% retrieve steady states
sslevel = real(this.assign);
ssgrowth = imag(this.assign);

% fix missing (=zero) growth in steady state of log variables
ssgrowth(ssgrowth == 0 & loglin(1,:,ones([1,nalt]))) = 1;

% retrieve dtrends
loglin = loglin(this.nametype == 1);
[const,ttrend] = dtrends_(this);
const = permute(const,[3,1,2]);
ttrend = permute(ttrend,[3,1,2]);
dtlevel = nan([1,ny,nalt]);
dtlevel(1,~loglin,:) = const(1,~loglin,:);
dtlevel(1,loglin,:) = exp(const(1,loglin,:));
dtgrowth = nan([1,ny,nalt]);
dtgrowth(1,~loglin,:) = ttrend(1,~loglin,:);
dtgrowth(1,loglin,:) = exp(ttrend(1,loglin,:));

% sstate cum dtrends
index = find(this.nametype == 1);
level = sslevel;
level(1,index,:) = level(1,index,:) + dtlevel;
growth = ssgrowth;
index = find(this.log(this.nametype == 1));
growth(1,index,:) = growth(1,index,:) .* dtgrowth(1,index,:);
index = find(~this.log(this.nametype == 1));
growth(1,index,:) = growth(1,index,:) + dtgrowth(1,index,:);

invalid = {};
varargout = {};
varargin = regexprep(varargin,'\s+','');
for i = 1 : length(varargin)
   attrib = varargin{i};
   [varargout{i},flag] = get_(this,lower(attrib),sslevel,ssgrowth,dtlevel,dtgrowth,level,growth);
   if ~flag
      % variables/parameter name or expression
      if length(attrib) > 1 && attrib(1) == '.'
         attrib = attrib(2:end);
      end
      index = strcmp(this.name,attrib);
      if any(index)
         varargout{i} = permute(sslevel(1,index,:) + 1i*ssgrowth(1,index,:),[2,3,1]);
         warning('iris:obsolete','Using GET function to access model parameters and/or steady states is deprecated, and will not be supported in future versions of IRIS. Use the "model.name_of_parameter" syntax instead.');
      else
         invalid{end+1} = attrib;
      end
      % invalid{end+1} = attrib;
    end
end
if ~isempty(invalid)
   multierror('Unrecognised model object attribute: "%s".',invalid);
end

end
% End of primary function

%********************************************************************
%! Subfunction get_().

function [x,unrecognised] = get_(this,attrib,sslevel,ssgrowth,dtlevel,dtgrowth,level,growth)
   
   [ny,nx,nf,nb,ne,np,nalt] = size_(this);
   realsmall = getrealsmall();
   unrecognised = true;

   % transform 3D ASSIGN array into 2D cell array to be used in struct
   num2cell_ = @(x) num2cell(permute(x,[2,3,1]),2);

   % check availability of solution
   chksolution = false;

  switch attrib

  case {'sstate','ssgrowth','sslevel','sstatelevel','sstategrowth','level','growth'}
    switch attrib
    case {'sstate'}
      x = sslevel + 1i*ssgrowth;
    case {'sstatelevel','sslevel','level'}
      x = sslevel;
    case {'sstategrowth','ssgrowth','growth'}
      x = ssgrowth;
    end
    x = cell2struct(num2cell_(x),vec(this.name),1);

  case {'dtrends','dtlevel','dtgrowth','dtrendslevel','dtrendsgrowth'}
    switch attrib
    case {'dtrends'}
      x = dtlevel + 1i*dtgrowth;
    case {'dtlevel','dtrendslevel'}
      x = dtlevel;
    case {'dtgrowth','dtrendsgrowth'}
      x = dtgrowth;
    end
    x = cell2struct(num2cell_(x),vec(this.name(this.nametype == 1)),1);

  case {'sstate_dtrends','sslevel_dtlevel','ssgrowth_dtgrowth','sstatelevel_dtrendslevel','ssgrowth_dtrendsgrowth'}
    switch attrib
    case {'sstate_dtrends'}
      x = level + 1i*growth;
    case {'sslevel_dtlevel','sstatelevel_dtrendslevel'}
      x = level;
    case {'ssgrowth_dtgrowth','sstategrowth_dtrendsgrowth'}
      x = growth;
    end
    x = cell2struct(num2cell_(x),vec(this.name),1);

  case {'pars','parameters'}
    index = this.nametype == 4;
    x = cell2struct(num2cell_(this.assign(1,index,:)),vec(this.name(index)),1);

  case {'std'}
    index = strmatch('std_',this.name);
    x = cell2struct(num2cell_(this.assign(1,index,:)),this.name(index),1);

  case {'eig','eigval','roots'}
    x = eig(this);

  case {'name','names'}
    x = cell([1,4]);
    for i = 1 : 4
      x{i} = this.name(this.nametype == i);
    end

  case {'yname','ynames','xname','xnames','ename','enames','pname','pnames','elist','xlist','ylist','plist'}
    type = find(attrib(1) == 'yxep');
    x = this.name(this.nametype == type);

  case {'stdname','stdnames','stdlist'}
     index = find(this.nametype == 4);
     index = index(end-ne+1:end);
     x = this.name(index);
     
  case {'rnames','rname'}
    x = {this.outside.lhs{:}};

  case {'ycomment','ycomments','xcomment','xcomments','ecomment','ecomments','pcomment','pcomments'}
    index = find(attrib(1) == 'yxep');
    x = this.namelabel(this.nametype == index);    

  case {'yeqtn','xeqtn','deqtn','leqtn','yeqtns','xeqtns','deqtns','leqtns','yequations','xequations','dequations','lequations'}
    index = find(attrib(1) == 'yxdl');
    if any(index == [1,2])
       x = this.eqtn(this.eqtntype == index);
    else
       nonemptyeqtn = ~cellfun(@isempty,this.eqtn);
       x = this.eqtn(this.eqtntype == index & nonemptyeqtn);
    end

  case {'reqtn','requations','reporting'}
    x = {};
    for i = 1 : length(this.outside.rhs)
      x{i} = sprintf('%s=%s;',this.outside.lhs{i},this.outside.rhs{i});
    end
    % Remove references to database d from reporting equations.
    x = regexprep(x,'d\.([a-zA-Z])','$1');

  case {'rlabel','rlabels'}
    x = this.outside.label;

  case {'yvector','xvector','evector'}
    index = find(attrib(1) == 'yxe');
    x = printid_(this,index);

  case 'log'
    x = struct();
    for i = find(this.nametype <= 3);
      x.(this.name{i}) = this.log(i);
    end

  case 'loglist'
    x = this.name(this.log);

  case {'ylog','xlog','elog'}
    index = find(attrib(1) == 'yxe');
    x = this.log(this.nametype == index);

  case {'eqtn','eqtns','equation','equations'}
    x = cell([1,4]);
    for i = 1 : 2
       x{i} = this.eqtn(this.eqtntype == i);
    end
    nonemptyeqtn = ~cellfun(@isempty,this.eqtn);
    for i = 3 : 4
       x{i} = this.eqtn(this.eqtntype == i & nonemptyeqtn);
    end

  case {'label','labels'}
    x = cell([1,4]);
    for i = 1 : 2
       x{i} = this.eqtnlabel(this.eqtntype == i);
    end
    nonemptyeqtn = ~cellfun(@isempty,this.eqtn);
    for i = 3 : 4
       x{i} = this.eqtnlabel(this.eqtntype == i & nonemptyeqtn);
    end

  case {'xlabel','xlabels','ylabel','ylabels','dlabel','dlabels','llabel','llabels'}
    index = find(attrib(1) == 'yxdl');
    if any(index == [1,2])
       x = this.eqtnlabel(this.eqtntype == index);
    else
       nonemptyeqtn = ~cellfun(@isempty,this.eqtn);
       x = this.eqtnlabel(this.eqtntype == index & nonemptyeqtn);
    end

  case {'comment','comments'}
    x = cell2struct(this.namelabel,this.name,2);

  case {'link','links'}
    x = cell2struct(this.eqtn(this.eqtntype == 4),this.name,2);
    
  case {'diffuse','nonstationary','stationary','stationarylist','nonstationarylist'}
    chksolution = true;
    id = [this.solutionid{1:2}];
    t0 = imag(id) == 0;
    name = this.name(real(id(t0)));
    [ans,index] = isnan(this,'solution');
    status = nan([sum(t0),nalt]);
    for ialt = find(~index)
      % index of non-stationary x and y variables
      [dy,df,db] = isdiffuse(this.eigval(1,:,ialt),this.solution{4}(:,:,ialt),this.solution{1}(1:nf,:,ialt),this.solution{7}(:,:,ialt));
      d = [dy,df,db];
      switch attrib
      case {'stationary','stationarylist'}
        status(:,ialt) = transpose(double(~d(t0)));
      otherwise
        status(:,ialt) = transpose(double(d(t0)));
      end
    end
    try
      status = logical(status);
    end
    % list versus database
    switch attrib
    case {'stationarylist','nonstationarylist'}
      x = vech(name(status == true | status == 1));
    otherwise
      x = cell2struct(num2cell(status,2),vec(name),1);
    end

  case {'icond','initcond','required','states','maxlag'}
    if isempty(this.solution{1}) || any(any(any(isnan(this.solution{1}))))
      id = this.systemid{2};
      id(imag(id) >= 0) = [];
      if attrib(1) == 'm' % maxlag
        x = min(imag(id));
      else
        id = id + 1i;
        x(1:nalt) = {printid(this.name(real(id)),imag(id)-iff(attrib(1) == 's',0,1))};
        if nalt == 1
          x = x{1};
        end
      end
    else
      id = this.solutionid{2}(nf+1:end);
      if attrib(1) == 'm' % maxlag
        x = min(imag(id)) - 1;
      else
        for ialt = 1 : nalt
          index = any(abs(this.solution{1}(:,:,ialt)/this.solution{7}(:,:,ialt)) > realsmall,1);
          x{ialt} = printid(this.name(real(id(index))),imag(id(index))-iff(attrib(1) == 's',0,1));
        end
        if nalt == 1
          x = x{1};
        end
      end
    end

  case {'forward'}
    ne = sum(this.nametype == 3);
    x = size(this.solution{2},2)/ne - 1;
    chksolution = true;

  case {'covmat','omega'}
    x = omega_(this);

  case {'stdvec'}
    x = this.assign(1,end-sum(this.nametype == 3)+1:end,:);

  case {'stableroots','unitroots','unstableroots'}
    switch attrib
    case 'stableroots'
      index = abs(this.eigval) < (1 - realsmall);
    case 'unstableroots'
      index = abs(this.eigval) > (1 + realsmall);
    case 'unitroots'
      index = abs(abs(this.eigval) - 1) <= realsmall;
    end
    x = nan(size(this.eigval));
    for ialt = 1 : nalt
      n = sum(index(1,:,ialt));
      x(1,1:n,ialt) = this.eigval(1,index(1,:,ialt),ialt);
    end
    x(:,all(isnan(x),3),:) = [];

  case {'nalt'}
    x = size(this.assign,3);

  case 'precision'
    x = this.precision;

  case 'epsilon'
    x = this.epsilon;

  case {'torigin','baseyear'}
    x = this.torigin;

  case 'userdata'
    x = this.userdata;

  case {'activeshocks','inactiveshocks'}
    x = cell([1,nalt]);
    for ialt = 1 : nalt
      list = this.name(this.nametype == 3);
      stdvec = this.assign(1,end-sum(this.nametype == 3)+1:end,ialt);
      if attrib(1) == 'a'    
         list(stdvec == 0) = [];
      else
         list(stdvec ~= 0) = [];
      end
      x{ialt} = list;
    end

   case {'fname','filename'}
      x = this.fname;
    
   otherwise
     x = [];
     unrecognised = false;

   end % of switch

   if chksolution
      % solution not available
      [solutionflag,index] = isnan(this,'solution');
      if solutionflag
         warning_(44,sprintf(' #%g',find(index)));
      end
   end

end
% End of subfunction get_().
