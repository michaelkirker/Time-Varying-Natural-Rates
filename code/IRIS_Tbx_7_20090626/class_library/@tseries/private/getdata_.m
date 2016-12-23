function [data,dates] = getdata_(x,dates,varargin)
%
% TSERIES/PRIVATE/GETDATA_  Get time series values for specific dates.
%
% The IRIS Toolbox 2007/10/23. Copyright 2007 Jaromir Benes. <a href="http://www.iris-toolbox.com">www.iris-toolbox.com</a>
% _______________________________________________________________________________

%% function body --------------------------------------------------------------------------------------------

if (isnumeric(dates) && any(isinf(dates))) || strcmp(dates,'max') || strcmp(dates,'min')
  if nargin > 2
    data = x.data(:,varargin{:});
  else
    data = x.data;
  end
  if strcmp(dates,'min')
    dates = x.start + (0 : size(x.data,1)-1);
    si = size(data);
    data = reshape(data,[si(1),prod(si(2:end))]);
    sample = all(~isnan(data),2);
    data = reshape(data(sample,:),[sum(sample),si(2:end)]);
    dates = dates(sample);
  else % Inf | 'max'
    dates = x.start + (0 : size(x.data,1)-1);
  end
elseif isempty(dates)
  dim = size(x.data);
  data = zeros([0,dim(2:end)],class(x.data));
else
  dates = dates(:);
  if nargin > 2
    [tmp,dim] = reshape_(x.data(:,varargin{:}));
  else
    [tmp,dim] = reshape_(x.data);
  end
  data = nan([length(dates),dim],class(x.data));
  if ~isempty(tmp)
    index = round(dates - x.start + 1);
    freqtest = abs((dates-floor(dates)) - (x.start-floor(x.start))) < 1e-2;
    pos = find(index >= 1 & index <= size(x.data,1) & freqtest);
    data(pos,:) = tmp(index(pos),:);
  end
  data = reshape_(data,dim);
end

end

% end of primary function -----------------------------------------------------------------------------------