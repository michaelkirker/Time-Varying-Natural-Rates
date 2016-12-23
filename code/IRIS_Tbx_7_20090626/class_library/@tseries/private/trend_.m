function [x,b] = trend_(x,order)
%
% Called from within tseries/trend.
%
% The IRIS Toolbox 2007/11/23. Copyright 2007 Jaromir Benes. <a href="http://www.iris-toolbox.com">www.iris-toolbox.com</a>
%

if nargin < 2
  order = 0;
end

% ###########################################################################################################
%% function body

if any(any(isnan(x)))
  b = nan([order+1,size(x,2)]);
  for i = 1 : size(x,2)
    sample = getsample(transpose(x(:,i)));
    [x(sample,i),b(:,i)] = esttrend_(x(sample,i),order);
  end
else
  [x,b] = esttrend_(x,order);
end

end
% end of primary function

% ###########################################################################################################
%% subfunction esttrend_()

  function [x,b] = esttrend_(x,order) 
  seas = round(100*(order - floor(order)));
  order = floor(order);
  nper = size(x,1);
  time = transpose(1 : nper);
  M = ones([nper,1]);
  for i = 1 : order
    M = [M,time.^i];
  end
  if seas > 0
    S = zeros([nper,seas-1]);
    for i = 1 : seas-1
      S(i:seas:end,i) = 1;
    end
    S(seas:seas:end,:) = -1;
    M = [M,S];
  end
  b = M \ x;
  x = M * b;
  end 
% end of subfunction esttrend_()