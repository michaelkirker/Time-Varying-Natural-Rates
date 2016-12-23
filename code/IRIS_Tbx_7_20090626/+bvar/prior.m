function X = prior(default,initfcn,yfcn,kfcn,gfcn,varargin)
% Called from within bvar.litterman, bvar.sumofcoeff, bvar.mean.

% The IRIS Toolbox 2008/10/03.
% Copyright (c) 2007-2008 Jaromir Benes.

% Find first char string input argument.
index = find(cellfun(@ischar,varargin),1);
options = passvalopt(default,varargin{index:end});

% Get data including pre-sample initial conditions.
% Range containes pre-sample.
[y,range] = getdata(options.order,varargin{1:index-1});

% =======================================================================================
%! Function body.

index = getsample(y);
y = y(:,index,:);
[ny,nper,ndata] = size(y);
p = options.order;

nloop = ndata;

[py0,pk0,py1,pg1] = initfcn(ny,nloop,options);

use = struct();
for iloop = 1 : nloop
   if iloop <= ndata
      use.ystd = std(y(:,:,iloop),1,2);
   end
   % Dummy observations for LHS and RHS of endogenous variables.   
   [a,b] = yfcn(use.ystd,options);
   [py0(:,:,iloop),py1(:,:,iloop)] = yfcn(use.ystd,options);
   % Dummy observations for constant.
   pk0(:,:,iloop) = kfcn(use.ystd,options);
   % Dummy observations for co-intergrating terms.
   pg1(:,:,iloop) = gfcn(use.ystd,options);
end

X = [py0;pk0;py1;pg1];

end
% End of primary function.