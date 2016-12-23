function [xtrend1,xtrend2] = dftrend_(x,season)
%
% Called from within tseries/dftrend_.
%
% The IRIS Toolbox 2007/05/03. Copyright 2007 Jaromir Benes. <a href="www.iris-toolbox.com">www.iris-toolbox.com</a>
%

if nargin < 2
  season = 0;
end

% ###########################################################################################################
%% function body

if any(any(isnan(x)))
  xtrend1 = nan(size(x));
  xtrend2 = nan(size(x));
  for i = 1 : size(x,2)
    sample = getsample(transpose(x(:,i)));
    [xtrend1(sample,i),xtrend2(:,i)] = trend_(x(sample,i),season);
  end
else
  [xtrend1,xtrend2] = trend_(x,season);
end

end
% end of primary function

% ###########################################################################################################
%% subfunction trend_()

  function [xtrend1,xtrend2] = trend_(x,season) 
  nper = size(x,1);
  nx = size(x,2);
  xtrend1 = zeros(size(x));
  xtrend2 = zeros(size(x));
  dx = diff(x,1,1);
  M = ones([nper-1,1]);
  if season > 1
    time = transpose(1 : nper-1);
    S = zeros([nper-1,season-1]);
    for i = 1 : season-1
      S(i:season:end,i) = 1;
    end
    S(season:season:end,:) = -1;
    M = [M,S];
    beta = M \ dx;
    dxtrend2 = M(:,2:end) * beta(2:end,:);
    xtrend2(2:end,:) = cumsum(dxtrend2,1);
    % center integrated seasonals on zero
    for i = 1 : nx
      xtrend2(:,i) = xtrend2(:,i) - mean(xtrend2(:,i),1);
    end
  else
    beta = mean(dx,1);
  end
  dxtrend1 = M(:,1) * beta(1,:);
  xtrend1(2:end,:) = cumsum(dxtrend1,1);
  % center detrended series on zero
  xmean = mean(x - xtrend1 - xtrend2,1);
  for i = 1 : nx
    xtrend1(:,i) = xtrend1(:,i) + xmean(1,i);
  end
  end 
% end of subfunction trend_()
