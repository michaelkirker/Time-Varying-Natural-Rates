function C = acovfsmp(x,varargin)
%
% TIME-DOMAIN/ACOVFSMP  Sample autocovariance function.
%
% The IRIS Toolbox 2007/05/03. Copyright 2007 Jaromir Benes. <a href="www.iris-toolbox.com">www.iris-toolbox.com</a>

default = {...
   'demean',true,...
   'order',0,...
   'smallsample',true,...
};
options = passopt(default,varargin{:});

% ===========================================================================================================
%! function body

[nper,nx] = size(x);

if isinf(options.order)
   options.order = nper - 1;
end

if options.demean == true
   M = mean(x);
   x = x - M(ones([1,nper]),:);
end

C = zeros([nx,nx,1+options.order]);
C(:,:,1) = transpose(x)*x / nper;
for i = 1 : options.order
   C(:,:,i+1) = transpose(x(1:end-i,:))*x(1+i:end,:) / iff(options.smallsample,nper-i,nper);
end

end
% end of primary function