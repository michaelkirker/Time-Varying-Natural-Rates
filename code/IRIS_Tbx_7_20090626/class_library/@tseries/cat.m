function x = cat(n,varargin)
% <a href="tseries/cat">CAT</a>  concatenate time series (and possibly numeric arrays) in n-th dimension.
%
% Syntax:
%   x = cat(n,x,y,...)
% Required input arguments:
%   x tseries|numeric;

% The IRIS Toolbox 2009/06/09.
% Copyright 2007-2009 Jaromir Benes.

%********************************************************************
%! Function body.

if length(varargin) == 1
  % Matlab calls horzcat(x) first for [x;y].
  x = varargin{1};
  return
end

% Check classes and frequencies.
[inputs,ixtseries] = catcheck_(varargin{:});

% Remove inputs with zero size in all higher dimensions.
% Remove empty numeric arrays.
remove = false(size(inputs));
for i = 1 : length(inputs)
  si = size(inputs{i});
  if all(si(2:end) == 0), remove(i) = true;
    elseif isnumeric(inputs{i}) && isempty(inputs{i}), remove(i) = true;
  end
end
inputs(remove) = [];
ixtseries(remove) = [];

if isempty(inputs)
  x = tseries([],[]);
  return
end

ninput = length(inputs);
% find minimum start and maximum end
start = nan([1,ninput]);
finish = nan([1,ninput]);
for i = find(ixtseries)
  start(i) = inputs{i}.start;
  finish(i) = start(i) + size(inputs{i}.data,1) - 1;
end

% find start and end dates
minstart = min(start(~isnan(start)));
maxfinish = max(finish(~isnan(finish)));
start(~ixtseries) = -Inf;
finish(~ixtseries) = Inf;

% expand data with pre- or post-sample NaNs
if ~isempty(minstart)
  for i = find(start > minstart | finish < maxfinish)
    dim = size(inputs{i}.data);
    if isnan(inputs{i}.start)
      inputs{i}.data = nan([round(maxfinish-minstart+1),dim(2:end)]);
    else
      inputs{i}.data = [nan([round(start(i)-minstart),dim(2:end)]);inputs{i}.data;nan([round(maxfinish-finish(i)),dim(2:end)])];
    end
  end
  for i = find(isnan(start))
    dim = size(inputs{i}.data);
    inputs{i}.data = nan([maxfinish-minstart+1,dim(2:end)]);
  end
  nper = maxfinish - minstart + 1;
else
  nper = 0;
end

% Struct for resulting tseries.
x = struct();
x.data = [];
if ~isempty(minstart)
  x.start = minstart;
else
  x.start = NaN;
end
x.comment = {};

% Add individual inputs.
for i = 1 : ninput
  if ixtseries(i)
    x.data = cat(n,x.data,inputs{i}.data);
    x.comment = cat(n,x.comment,inputs{i}.comment);
  else
    data = inputs{i};
    si = size(data);
    if si(1) < nper
      data = data(:,:);
      data = [data;data(ones([1,nper-si(1)])*end,:)];
      data = reshape(data,[nper,si(2:end)]);
    end
    comment = cell([1,si(2:end)]);
    comment(:) = {''};
    x.data = cat(n,x.data,data);
    x.comment = cat(n,x.comment,comment);
  end
end

% Convert struct to tseries.
x = tseries(x);

end
% End of primary function.