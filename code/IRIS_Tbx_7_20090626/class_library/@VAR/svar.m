function [this,data,B] = svar(this,data,varargin)
% <a href="matlab: edit VAR/svar">SVAR</a>  Identify structural VAR from reduced-form VAR.
%
% Syntax:
%   [this,data,B] = svar(this,data,...)
% Output arguments:
%   this [ VAR ] Identified structural VAR model.
%   data [ tseries ] Multivariate time series associated with identified structural VAR.
% Required input arguments:
%   this [ VAR ] Input VAR model.
%   data [ tseries ] Multivariate time series associated with input VAR.
% <a href="options.html">Optional input arguments:</a>
%   'method' [ <a href="default.html">'chol'</a> | 'qr' ] Type of identifying restrictions.
%   'std' [ numeric | <a href="default.html">1</a> ] Standard deviation of structural shocks.
%   'ordering' [ numeric | <a href="default.html">empty</a> ] Re-order variables and shocks.

% The IRIS Toolbox 2008/10/258.
% Copyright 2007 Jaromir Benes.

default = {
   'method','chol',@(x) any(strcmpi(x,{'chol','qr'})),...
   'std',1,@isnumeric,...
   'ordering',[],@isnumeric,...
   'reorderresiduals',true,@islogical,...
};
options = passvalopt(default,varargin{1:end});

%********************************************************************
%! Function body.

try
   import('time_domain.*');
end

realsmall = getrealsmall();

if ~isvar(this)
   error('Incorrect type of input argument(s).');
end

[ny,p,nalt] = size(this);
A = var2poly(this.A);
Omega = this.Omega;

if ~isempty(options.ordering)
   options.ordering = vech(options.ordering);
   if ~( length(options.ordering) == ny && length(intersect(1:ny,options.ordering)) == ny )
      error_(14);
   end
   A = A(options.ordering,options.ordering,:,:);
   Omega = Omega(options.ordering,options.ordering,:);
end

% expand options.std
if nalt > 1 && length(options.std) == 1
   options.std = options.std(ones([1,nalt]));
else
   options.std = vech(options.std);
end

B = nan([ny,ny,nalt]);

switch lower(options.method)
case 'chol'
   for ialt = 1 : nalt
      B(:,:,ialt) = transpose(chol(Omega(:,:,ialt)));
   end
case 'qr'
   C = sum(A,3);
   for ialt = 1 : nalt
      B0 = transpose(chol(Omega(:,:,ialt)));
      if rank(C(:,:,1,ialt)) == ny
         [Q,R] = qr(transpose(C(:,:,1,ialt)\B0));
      else
         [Q,R] = qr(transpose(pinv(C(:,:,1,ialt))*B0));
      end
      B(:,:,ialt) = B0*Q;
   end
otherwise
   error(['Unrecognised identifying restrictions: ''',options.method,'''.']);
end

% Re-order variables and (and residuals, if requested) back.
if ~isempty(options.ordering)
   [aux,backorder] = sort(options.ordering);
   if options.reorderresiduals
      B = B(backorder,backorder,:);
   else
      B = B(backorder,:,:);
   end
end

% Scale standard deviations of structural shocks.
for ialt = 1 : nalt
   stdi = options.std(ialt);
   if stdi ~= 1
      B(:,:,ialt) = B(:,:,ialt)/stdi;
   end
end

% Convert reduced-form shocks to structural shocks.
if nargin > 1 && ~isempty(data)
   range = get(data,'range');
   data = data(:,:,:);
   if size(data,3) == 1 && nalt > 1
      data = data(:,:,ones([1,nalt]));
   end
   for iloop = 1 : size(data,3)
      if iloop <= nalt
         Bi = B(:,:,iloop);
      end
      data(:,ny+1:end,iloop) = data(:,ny+1:end,iloop) / transpose(Bi);
   end
   data = tseries(range,data);
end

% Structural VAR properties.
this.B = B;
this.std = options.std;

end
% End of primary function.