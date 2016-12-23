function [y0,y1,k0,g1] = stackdata(y,options)

% ===========================================================================================================
%! Function body.

[ny,nper,nalt] = size(y);
p = options.order;

% Current date and lagged endogenous variables.
t = 1+p : nper;

% Add cointegrating vector and differentiate data.
if isempty(options.cointeg) || nargout < 4
   g1 = zeros([0,nper-p,nalt]);
   y0 = y(:,t,:);
   y1 = zeros([0,nper-p,nalt]);
   for i = 1 : p
      y1 = [y1;y(1:end,t-i,:)];
   end      
else
   ng = size(options.cointeg,1);
   g1 = zeros([ng,nper-p,nalt]);
   if size(options.cointeg,2) == ny+1
      kg = ones([1,nper-p]);
   else
      kg = ones([0,nper-p]);
   end
   for iloop = 1 : nalt
      g1(:,:,iloop) = options.cointeg*[kg;y(:,t-1,iloop)];
   end
   y0 = y(:,t,:) - y(:,t-1,:);
   y1 = zeros([0,nper-p,nalt]);
   for i = 1 : p-1
      y1 = [y1;y(:,t-i,:) - y(:,t-i-1,:)];
   end
end

% Constant.
if options.constant
   k0 = ones([1,nper-p]);
else
   k0 = ones([0,nper-p]);
end
   
end
% End of primary function.