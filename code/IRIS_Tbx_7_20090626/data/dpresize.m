function dpack = dpresize(dpack,range)
%
% <a href="data/dpresize">DPRESIZE</a>  Resize datapack in time dimension.
%
% Syntax:
%   dpack = dpresize(dpack,range)
% Output arguments:
%   dpack [ cell ] Resized datapack.
% Required input arguments:
%   dpack [ cell ] Datapack to be resized.
%   range [ numeric ] New time range, i.e. <a href="dates.html">IRIS serial date numbers</a>.
%
% The IRIS Toolbox 2008/04/22. Copyright 2007-2008 Jaromir Benes. <a href="http://www.iris-toolbox.com">www.iris-toolbox.com</a>
%

% ###########################################################################################################
%% function body

if length(range) == 1 && isinf(range)
  return
end

if round(dpack{4}(1) - range(1)) == 0 && round(dpack{4}(end) - range(end)) == 0
  return
end

oldrange = dpack{4};
if length(range) == 2
  if isinf(range(1)) && range(1) < 0
    range(1) = oldrange(1);
  end
  if isinf(range(2)) && range(2) > 0
    range(2) = oldrange(end);
  end
end
newrange = range(1) : range(end);

% new range == old range
if round(newrange(1) - oldrange(1)) == 0 && round(newrange(end) - oldrange(end)) == 0
  return
end

% mean or mse datapack
mse = isfield(dpack{5},'mse') && dpack{5}.mse;

index = round(newrange - oldrange(1)) + 1;
npre = sum(index < 1);
npost = sum(index > length(oldrange));
index = index(index >= 1 & index <= length(oldrange));

% bring time to 1st dimension
if mse
  % time in 3rd dimension
  for i = 1 : 3
    dpack{i} = permute(dpack{i},[3,1,2,4]);
  end
else
  % time in 2nd dimension
  for i = 1 : 3
    dpack{i} = permute(dpack{i},[2,1,3]);
  end
end

for i = 1 : 3
  precision = class(dpack{i});
  si = size(dpack{i});
  dpack{i} = [...
    nan([npre,si(2:end)],precision);...
    dpack{i}(index,:,:,:);...
    nan([npost,si(2:end)],precision);...
  ];
end
dpack{4} = newrange;

% bring time back to 2nd or 3rd dimension
if mse
  % time in 3rd dimension
  for i = 1 : 3
    dpack{i} = permute(dpack{i},[2,3,1,4]);
  end
else
  % time in 2nd dimension
  for i = 1 : 3
    dpack{i} = permute(dpack{i},[2,1,3]);
  end
end

end
%% end of primary function