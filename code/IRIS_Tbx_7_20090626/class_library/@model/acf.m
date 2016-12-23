function [CC,RR,list] = acf(this,varargin)
% To get help for this IRIS function
% * type <a href="matlab: idoc model.acf">idoc model.acf</a>, or
% * open <a href="matlab: helpbrowser">Matlab Product Help</a> and browse The IRIS Toolbox documentation in the Contents pane.

% The IRIS Toolbox 2009/01/21.
% Copyright 2007-2009 Jaromir Benes.

if nargin > 1 && isnumeric(varargin{1})
   warning('iris:obsolete','This is an obsolete ACF syntax.');
   options.order = varargin{1};
   varargin(1) = [];
end

default = {
   'applyto',Inf,@(x) (isnumeric(x) && all(isinf(x))) || iscellstr(x) || ischar(x),...
   'filter','',@ischar,...
   'nfreq',256,@isnumericscalar,...
   'order',0,@isnumericscalar,...
   'select',Inf,@(x) (isnumeric(x) && all(isinf(x))) || iscellstr(x) || ischar(x),...
};
options = passvalopt(default,varargin{:});

if ischar(options.applyto) && ~isempty(options.applyto)
   options.applyto = charlist2cellstr(options.applyto);
end

if ischar(options.select)
   options.select = charlist2cellstr(options.select);
elseif isempty(options.select)
   options.select = {''};
end

%********************************************************************
%! Function body.

try
   import('time_domain.*','freq_domain.*');
end

[ny,nx,nf,nb,ne,np,nalt] = size_(this);
CC = nan([ny+nx,ny+nx,options.order+1,nalt]);
if nargout > 1
   RR = nan([ny+nx,ny+nx,options.order+1,nalt]);
end

% linear filter applied to some variables
if isnumeric(options.applyto) && any(isinf(options.applyto))
   applyto = true([1,ny+nx]);
elseif ~isempty(options.applyto)
   applyto = regexprep(options.applyto,'log\((.*?)\)','$1');
   applyto = regexprep(applyto,'\{.*?\}','');
   applyto = ...
      findnames(this.name(this.nametype == 1 | this.nametype == 2),options.applyto);
   index = isnan(applyto);
   if any(index)
      warning_(1,options.applyto(index));
   end
   applyto(index) = [];
   aux = applyto;
   id = real([this.solutionid{1:2}]);
   applyto = false([1,ny+nx]);
   for i = vech(aux)
      applyto = applyto | id == i;
   end
else
   applyto = false([1,ny+nx]);
end

if ~isempty(options.filter) && any(applyto)
   isfilter = true;
   % Call Freq Domain package.
   [frq,filter] = fdfilter(options.nfreq,options.filter);
   nfrq = lenght(frq);
else
   isfilter = false;
end

% solution not available for some parameterisations
[flag,nans] = isnan(this,'solution');
if flag
   warning_(44,sprintf(' #%g',find(nans)));
end

% autocovariance function
for ialt = find(~nans)
   [T,R,K,Z,H,D,U,Omega] = sspace_(this,ialt,false);
   if isfilter
      % We should multiply by 2*width == 2*pi/nfreq but we skip
      % dividing S by 2*pi in XSF and hence skip multiplying it by
      % 2*pi here.
      CC(:,:,:,ialt) = ...
         real(xsf(T,R,K,Z,H,D,U,Omega,frq,filter,applyto,options.order)) ...
         / nfrq;
   else
      CC(:,:,:,ialt) = ...
         acovf(T,R,K,Z,H,D,U,Omega,this.eigval(1,:,ialt),options.order);
   end
end

% Fix negative variances.
tmpsize = size(CC);
if length(tmpsize) < 4
   tmpsize(end+1:4) = 1;
end
CC0 = reshape(CC(:,:,1,:),[tmpsize(1:2),tmpsize(4)]);
CC0 = fixcov(CC0);
CC(:,:,1,:) = reshape(CC0,[tmpsize(1:2),1,tmpsize(4)]);

% autocorrelation function
if nargout > 1
   % Call Time Domain package.
   % Convert covariances to correlations.
   RR = cov2corr(CC);
end

% list of variables
if nargout > 2 || iscellstr(options.select)
   list = printid_(this);
   list = list(1:ny+nx);
end

% select variables
if iscellstr(options.select)
  [CC,index,list,notfound] = select(CC,list,options.select);
  if nargout > 1
    RR = RR(index,index,:,:);
  end
  if ~isempty(notfound)
    warning_(1,notfound);
  end
end

end
% End of primary function.
