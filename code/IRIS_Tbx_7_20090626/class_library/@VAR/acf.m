function [C,Q] = acf(this,varargin)
%
% <a href="matlab: edit VAR/acf">ACF</a>  Autocovariance and autocorrelation functions.
%
% Syntax:
%   [C,R] = acf(this,...)
% Output arguments:
%   C [ numeric ] Autocovariance function.
%   R [ numeric ] Autocorrelation function.
% Required input arguments:
%   this [ VAR ] VAR model.
% <a href="options.html">Optional input arguments:</a>
%   'applyto' [ logical | numeric | <a href="default.html">Inf</a> ] Index of variables to apply the filter to before ACF is computed.
%   'filter' [ char | <a href="default.html">empty</a> ] Time-domain or frequency-domain filter.
%   'nfreq' [ numeric | <a href="default.html">256</a> ] Number of evenly spaced frequencies to integrate over in the frequency domain when computing filtered ACF.
%   'order' [ numeric | <a href="default.html">0</a> ] Maximum order of autocovariance or autocorrelation computed.
%
% The IRIS Toolbox 2007/10/11. Copyright 2007 Jaromir Benes. <a href="http://www.iris-toolbox.com">www.iris-toolbox.com</a>

%!

[ny,p,nalt] = size(this);

default = {
   'applyto',Inf,@isnumericscalar,...
   'filter','',@ischar,...
   'nfreq',256,@isnumericscalar,...
   'order',0,@isnumericscalar,...
};
options = passvalopt(default,varargin{:});

if isinf1(options.applyto)
   options.applyto = true([1,ny]);
elseif ~islogical(options.applyto)
   aux = options.applyto;
   options.applyto = false([1,ny]);
   options.applyto(aux) = true;
end

% ===========================================================================================================
%! function body

try
   % Try to import Time Domain package.
   % Try to import Freq Domain package.
   import('time_domain.*','freq_domain.*');
end

realsmall = getrealsmall();

% linear filter applied to some variables
if ~isempty(options.filter) && any(options.applyto)
   isfilter = true;
   % Call Freq Domain package.
   [frq,filter] = fdfilter(options.nfreq,options.filter);
else
   isfilter = false;
end

C = nan([ny,ny,options.order+1,nalt]);
% find explosive parameterisations
explosive = isexplosive(this);
for ialt = find(~explosive)  
   [T,R,K,Z,H,D,U,Omega] = sspace(this,ialt);
   if isfilter
      % we should multiply by 2*width == 2*pi/nfreq but we skip dividing S by 2*pi in XSFVAR and hence skip ultiplying it by 2*pi here
      C(:,:,:,ialt) = real(xsfvar(this.A(:,:,ialt),Omega,frq,filter,options.applyto,options.order))/options.nfreq;
   else
      % Call Time Domain package.
      % Compute contemporaneous ACF for its first-order state space form.
      % This gives us autocovariances up to order p-1.
      c = acovf(T,R,[],[],[],[],U,Omega,this.eigval(1,:,ialt),0);     
      if p > 1
         c0 = c;
         c = reshape(c0(1:ny,:),[ny,ny,p]);
      end
      if p == 0
         c(:,:,end+1:options.order+1) = 0;
      elseif options.order > p - 1      
         % Call Time Domain package.
         % Compute higher-order acfs using Yule-Walker equations.
         c = acovfyw(this.A(:,:,ialt),c,options.order);         
      else
         c = c(:,:,1:1+options.order);
      end
      C(:,:,:,ialt) = c;
   end
end

if any(explosive)
   % Explosive parameterisations.
   warning_(10,sprintf(' #%g',find(explosive)));
end

% Call Time Domain package.
% Fix entries with negative variances.
C = fixcov(C);

% autocorrelation function
if nargout > 1
   % Call Time Domain package.
   % Convert covariances to correlations.
   Q = cov2corr(C);
end

end
% end of primary function