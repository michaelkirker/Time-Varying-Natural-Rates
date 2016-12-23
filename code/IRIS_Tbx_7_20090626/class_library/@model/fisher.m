function [F,Fi,delta,freq,G,step] = fisher(this,nper,plist,varargin)
% FISHER  Frequency-domain Fisher information matrix wrt selected parameters.

% The IRIS Toolbox 2009/02/19.
% Copyright 2007-2009 Jaromir Benes.

% Validate required input arguments.
p = inputParser();
p.addRequired('this',@(x) isa(x,'model'));
p.addRequired('nper',@(x) isnumeric(x) && length(x) == 1);
p.addRequired('plist',@(x) iscellstr(x) || ischar(x));
p.parse(this,nper,plist);

% Read and validate optional input arguments.
default = {...
   'chksgf',false,@islogical,...
   'display',false,@islogical,...
   'epspower',1/3,@isnumeric,...
   'refresh',true,@islogical,...
   'solve',true,@islogical,...
   'sstate',[],@(x) isempty(x) || isa(x,'function_handle'),...
   'deviation',true,@islogical,...
   'sstateeffect',[],@(x) isempty(x) || islogical(x),...
   'tolerance',eps()^(2/3),@isnumeric,...
};
[options,varargin] = extractopt(default(1:3:end),varargin{:});
options = passvalopt(default,options{:});

% Old option 'sstateeffect' maintained for bkw compatibility.
if ~isempty(options.sstateeffect)
   warning('iris:model',...
   'The option ''sstateeffect'' in FISHER is deprecated. Use ''deviation'' instead.');
   options.deviation = ~options.sstateeffect;
end

% Use loglikopt_ to process the 'exclude' option.
tmpoptions = loglikopt_(this,[],NaN,varargin{:});
options.exclude = tmpoptions.exclude;

if ischar(plist)
   plist = charlist2cellstr(plist);
end

% TODO: for linear models, no sstate function needs to be specified.
% Automatically use model/sstate instead.
if isempty(options.sstate) && ~options.deviation
   error(['Inconsistency in options ''sstate'' and ''deviation''.',...
      'Cannot include steady-state effect with no steady-state function specified.']);
end

%********************************************************************
%! Function body.

[ny,nx,nf,nb,ne,np,nalt] = size_(this);
ny = ny - sum(options.exclude);
nplist = length(plist);
[plist,pindex1,pindex2] = getpindex_(this,plist);
npindex1 = length(pindex1);
nfreq = floor(nper/2) + 1;
freq = 2*pi*(0:nfreq-1)/nper;
realsmall = getrealsmall();

% Kronecker delta vector.
% Different for even or odd number of periods.
delta = ones([1,nfreq]);
if mod(nper,2) == 0
   delta(2:end-1) = 2;
else
   delta(2:end) = 2;
end

Fi = nan([nplist,nplist,nfreq,nalt]);
F = nan([nplist,nplist,nalt]);

nonstationary = [];
for ialt = 1 : nalt
   if options.display
      display_(1);
   end

   % Fetch the i-th parameterisation.
   m = this(ialt);

   % SGF and inverse SGF at p0.
   [T0,R0,Z0,H0,Omg0,nunit0,flag] = getsspace_();
   if ~flag
      % Some measurement variables are non-stationary.
      nonstationary(end+1) = ialt;
      continue
   end
   [G,Gi] = sgfy_(T0,R0,Z0,H0,Omg0,nunit0,freq,options);
   
   % Compute derivatives of SGF and steady state
   % wrt the selected parameters.
   dG = nan([ny,ny,nfreq,npindex1]);
   if ~options.deviation
      ylist = m.name(m.nametype == 1);
      ylog = m.log(m.nametype == 1);
      ylist(options.exclude) = [];
      ylog(options.exclude) = [];   
      dy = nan([ny,npindex1]);
      P = cell2struct(num2cell(m.assign),m.name,2);
   end
   % Determine differentiation step.
   p0 = m.assign(1,pindex1);
   step = max([abs(p0);ones([1,npindex1])],[],1)*eps()^options.epspower;
   pp = p0 + step;
   pm = p0 - step;
   twosteps = pp - pm;
   for i = 1 : npindex1
      if options.display
         display_(2);
      end
      % State space and SGF at p0 + step.
      [m,npath] = updatemodel_(m,pp(i),pindex1(i),options);
      if npath ~= 1
         failed(m,npath,'fisher');
      end
      [Tp,Rp,Zp,Hp,Omgp,nunitp] = getsspace_();
      Gp = sgfy_(Tp,Rp,Zp,Hp,Omgp,nunitp,freq,options);
      % State space and SGF at p0 - step.
      [m,npath] = updatemodel_(m,pm(i),pindex1(i),options);
      if npath ~= 1
         failed(m,npath,'fisher');
      end
      [Tm,Rm,Zm,Hm,Omgm,nunitm] = getsspace_();
      Gm = sgfy_(Tm,Rm,Zm,Hm,Omgm,nunitm,freq,options);
      % Differentiate SGF.
      dG(:,:,:,i) = (Gp - Gm) / twosteps(i);
      % Reset p0.
      m.assign(1,pindex1(i)) = p0(i);
      if ~options.deviation
         % Differentiate steady state wrt the selected parameters.
         name = m.name{pindex1(i)};
         P.(name) = pp(i);
         P = options.sstate(P);
         yp = fetchysstate_(P,ylist,ylog);
         P.(name) = pm(i);
         P = options.sstate(P);
         ym = fetchysstate_(P,ylist,ylog);
         dy(:,i) = (yp - ym) / twosteps(i); 
         P.(name) = p0(i);
      end
   end
   
   % Compute Fisher information matrix.
   % Steady-state-independent part.
   for i = 1 : npindex1
      if options.display
         display_(3);
      end
      for j = i : npindex1
         fi = zeros([1,nfreq]);
         f = 0;
         for k = 1 : nfreq
            fi(k) = trace(real(Gi(:,:,k)*dG(:,:,k,i)*Gi(:,:,k)*dG(:,:,k,j)));
         end
         if ~options.deviation
            % Add steady-state effect to zero frequency.
            % We don't divide the effect by 2*pi because
            % we skip dividing G by 2*pi, too.
            A = dy(:,i)*dy(:,j)';
            fi(1) = fi(1) + nper*trace(Gi(:,:,1)*(A + A'));
         end
         Fi(pindex2(i),pindex2(j),:,ialt) = fi;
         Fi(pindex2(j),pindex2(i),:,ialt) = fi;
         f = delta*fi';
         F(pindex2(i),pindex2(j),ialt) = f;
         F(pindex2(j),pindex2(i),ialt) = f;
      end
   end
   
end

Fi = Fi / 2;
F = F / 2;

if ~isempty(nonstationary)
   warning_(54,sprintf(' #%g',nonstationary));
end





%********************************************************************
%! Nested function display_().
   function display_(level)
      switch level
      case 1
         fprintf(1,...
            'Parameterisation %g of %g.\n',...
            ialt,nalt);
      case 2
         fprintf(1,...
            '\tCalculating derivatives of SGF w.r.t. to "%s" (%g of %g).\n',...
            plist{i},i,npindex1);
      case 3
         fprintf(1,...
            '\tCalculating row %g of %g of Fisher matrix.\n',...
            i,npindex1);
      end
   end
% End of nested function display_().





%********************************************************************
%! Nested function getsspace_().
   function [T,R,Z,H,Omg,nunit,flag] = getsspace_()
      T = m.solution{1};
      [nx,nb] = size(T);
      nf = nx - nb;
      nunit = sum(abs(abs(m.eigval(1,1:nb))-1) <= realsmall);
      Z = m.solution{4}(~options.exclude,:);
      % Check for (non)stationarity of observables
      stationaryIndex = all(abs(Z(:,1:nunit)) <= realsmall,1);
      flag = all(stationaryIndex);
      if ~flag
         T = [];
         R = [];
         Z = [];
         H = [];
         Omg = [];
         nunit = [];
         return
      end   
      T = T(nf+nunit+1:end,nunit+1:end);
      Z = Z(:,nunit+1:end);
      % Cut off forward expansion.
      ne = sum(m.nametype == 3);
      R = m.solution{2}(nf+nunit+1:end,1:ne);
      H = m.solution{5}(~options.exclude,1:ne);
      Omg = omega_(m);
   end
% End of nested function getsspace_().





end
% End of primary function.





%********************************************************************
%! Subfunction sgfy_().
% Spectrum generating function and inverse SGF if requested.
% Computationally optimised for observables.
function [G,Gi] = sgfy_(T,R,Z,H,Omg,nunit,freq,options)
   [ny,nb] = size(Z);
   nfreq = length(freq(:));
   Sgm1 = R*Omg*R';
   Sgm2 = H*Omg*H';
   ny = size(Z,1);
   G = nan([ny,ny,nfreq]);
   for i = 1 : nfreq
      X = Z/(eye(nb) - T*exp(-1i*freq(i)));
      G(:,:,i) = symmetric_(X*Sgm1*X' + Sgm2);
   end
   % Do not divide G by 2*pi.
   % First, this cancels out in Gi*dG*Gi*dG
   % and second, we do not divide the steady-state effect
   % by 2*pi either.
   if nargout > 1
      Gi = nan([ny,ny,nfreq]);
      if options.chksgf
         for i = 1 : nfreq
            Gi(:,:,i) = pinverse_(G(:,:,i),options.tolerance);
         end
      else         
         for i = 1 : nfreq
            Gi(:,:,i) = inv(G(:,:,i));
         end
      end
   end
end
% End of subfunction sgfy_().





%********************************************************************
%! Subfunction symmetric_().
% Minimise numerical inaccuracy between upper and lower parts
% of symmetric matrices.
function x = symmetric_(x)
   index = eye(size(x)) == 1;
   x = (x + x')/2;
   x(index) = real(x(index));
end
% End of subfunction symmetric_().





%********************************************************************
%! Subfunction fetchysstate_().
% Fetch steady state for observables from steady-state database.
function y = fetchysstate_(P,ylist,ylog)
   ny = length(ylist);
   y = nan([ny,1]);
   for i = 1 : ny
      y(i) = P.(ylist{i});
   end
   y(ylog) = log(y(ylog));
end
% End of subfunction fetchysstate_().





%********************************************************************
%! Subfuntion pinverse_().
function X = pinverse_(A,tol)
   if isempty(A)
     X = zeros(size(A'),class(A));  
     return
   end
   [m,n] = size(A);
   s = svd(A);
   r = sum(s/s(1) > tol);
   if r == 0
      X = zeros(size(A'),class(A));
   elseif r == m
      X = inv(A);
   else
      [U,S,V] = svd(A,0);
      S = diag(1./s(1:r));
      X = V(:,1:r)*S*U(:,1:r)';
   end
end
% End of subfunction pinverse_().
