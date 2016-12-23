function X = uncmean(varargin)
% Unconditional mean priors for BVARs.

% The IRIS Toolbox 2008/10/03.
% Copyright (c) 2007-2008 Jaromir Benes.

default = {...
   'nobs',1,@(x) isnumeric(x) && all(x > 0),...
   'order',1,@(x) isnumeric(x) && length(x) == 1,...
   'mean',[0,0,0] ,@(x) isnumeric(x),...
   'scale',true,@islogical,...
};

% =======================================================================================
%! Function body.

X = bvar.prior(default,@initfcn_,@yfcn_,@kfcn_,@gfcn_,varargin{:});

% =======================================================================================
%! Nested function initfcn_().

function [py0,pk0,py1,pg1] = initfcn_(ny,nloop,options)
   p = options.order;
   py0 = zeros([ny,1,nloop]);
   py1 = zeros([ny*p,1,nloop]);
   pk0 = zeros([1,1,nloop]);
   pg1 = zeros([ny,1,nloop]);
end
% End of nested functiono initfcn_().

% =======================================================================================
%! Nested function yfcn_().

function [py0,py1] = yfcn_(ystd,options)
   % LHS and RHS of endogenous variables.
   ny = size(ystd,1);
   lambda = sqrt(options.nobs);
   ybar = options.mean;
   if length(ybar) == 1
      ybar = ybar(ones([1,ny]));
   end
   py0 = options.nobs*vec(ybar);
   py1 = repmat(options.nobs*vec(ybar),[options.order,1]);
end

% =======================================================================================
%! Nested function kfcn_().

function pk0 = kfcn_(ybar,options)
   % Constants.
   % By default, dummies contain 1 row for constant terms.
   pk0 = options.nobs*1;
end
% End of nested function kfcn_().

% =======================================================================================
%! Nested function gfcn_().

function pg1 = gfcn_(ybar,options)
   % Co-integrating vectors.
   % By default, dummies must contain ny rows for co-integrating terms.
   ny = size(ybar,1);
   pg1 = zeros([ny,1]);
end
% End of nested function gfcn_().

end
% End of primary function.