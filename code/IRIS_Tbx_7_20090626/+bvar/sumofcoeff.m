function X = sumofcoeff(varargin)
% Sum of coeffs priors for BVARs.

% The IRIS Toolbox 2008/10/03.
% Copyright (c) 2007-2008 Jaromir Benes.

default = {...
   'nobs',1,@(x) isnumeric(x) && all(x > 0),...
   'order',1,@(x) isnumeric(x) && length(x) == 1,...
   'sumofcoeff',1,@(x) isnumeric(x) && length(x) == 1,...
};

% =======================================================================================
%! Function body.

X = bvar.prior(default,@initfcn_,@yfcn_,@kfcn_,@gfcn_,varargin{:});

% =======================================================================================
%! Nested function initfcn_().

function [py0,pk0,py1,pg1] = initfcn_(ny,nloop,options)
   p = options.order;
   py0 = zeros([ny,ny,nloop]);
   py1 = zeros([ny*p,ny,nloop]);
   pk0 = zeros([1,ny,nloop]);
   pg1 = zeros([ny,ny,nloop]);
end
% End of nested functiono initfcn_().

% =======================================================================================
%! Nested function yfcn_().

function [py0,py1] = yfcn_(ystd,options)
   % LHS and RHS of endogenous variables.
   lambda = sqrt(options.nobs);
   ny = size(ystd,1);
   py0 = diag(vec(options.sumofcoeff).*vec(lambda).*ystd);
   py1 = diag(vec(lambda).*ystd);
   if options.order > 1
      py1 = repmat(py1,[options.order,1]);
   end
end

% =======================================================================================
%! Nested function kfcn_().

function pk0 = kfcn_(ystd,options)
   % Constants.
   % By default, dummies contain 1 row for constant terms.
   ny = size(ystd,1);
   pk0 = zeros([1,ny]);
end
% End of nested function kfcn_().

% =======================================================================================
%! Nested function gfcn_().

function pg1 = gfcn_(ystd,options)
   % Co-integrating vectors.
   % By default, dummies must contain ny rows for co-integrating terms.
   ny = size(ystd,1);
   pg1 = zeros([ny,ny]);
end
% End of nested function gfcn_().

end
% End of primary function.