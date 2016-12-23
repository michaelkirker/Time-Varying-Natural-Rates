function [dpack,found] = dpset(dpack,name,dates,x)
%
% The IRIS Toolbox 2007/05/03. Copyright 2007 Jaromir Benes. <a href="www.iris-toolbox.com">www.iris-toolbox.com</a>

if ~iscell(dpack) || ~ischar(name) || ~isnumeric(dates) || ~isnumeric(x)
  error('Incorrect type of input argument(s).');
end

%% function body --------------------------------------------------------------------------------------------

if any(isinf(dates))
  dates = dpack{4};
else
  dates = vech(dates);
end
if length(x) == 1 && length(dates) > 1
  x = x(ones([1,length(dates)]));
end

nameindex = find(strcmp(dpack{5}.name,name));
if isempty(nameindex)
  found = false;
  return
else
  found = true;
end

time = round(dates - dpack{4}(1)) + 1;
rhsindex = time >= 1 & time <= length(dpack{4});
time = time(rhsindex);
nper = length(time);
if size(x,2) == 1 && nper > 1, x = x(:,ones([1,nper]),:); end

if dpack{5}.nametype(nameindex) == 1
  if size(x,3) == 1 && size(dpack{1},3) > 1, x = x(:,:,ones([1,size(dpack{1},3)])); end
  tmp = find(dpack{5}.id{1} == nameindex);
  dpack{1}(tmp,time,:) = x(1,rhsindex,:);
elseif dpack{5}.nametype(nameindex) == 2
  if size(x,3) == 1 && size(dpack{2},3) > 1, x = x(:,:,ones([1,size(dpack{2},3)])); end
  tmp = find(dpack{5}.id{2} == nameindex);
  dpack{2}(tmp,time,:) = x(1,rhsindex,:);
else
  if size(x,3) == 1 && size(dpack{3},3) > 1, x = x(:,:,ones([1,size(dpack{3},3)])); end
  tmp = find(dpack{5}.id{3} == nameindex);
  dpack{3}(tmp,time,:) = x(1,rhsindex,:);
end

end

%% end of primary function ----------------------------------------------------------------------------------