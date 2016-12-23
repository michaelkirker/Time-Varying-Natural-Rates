function [x,found] = dpget(dpack,name,dates)
%
% The IRIS Toolbox 2007/05/03. Copyright 2007 Jaromir Benes. <a href="www.iris-toolbox.com">www.iris-toolbox.com</a>

if ~ischar(name) || ~isnumeric(dates)
  error('Incorrect type of input argument(s).');
end

% function body ---------------------------------------------------------------------------------------------

x = [];
if any(isinf(dates)), dates = dpack{4};
  else, dates = vech(dates); end
nameindex = find(strcmp(dpack{5}.name,name));
if isempty(nameindex), found = false, return
  else, found = true; end

time = round(dates - dpack{4}(1)) + 1;
lhsindex = time >= 1 & time <= length(dpack{4});
time = time(lhsindex);

if dpack{5}.nametype(nameindex) == 1
  tmp = find(dpack{5}.id{1} == nameindex);
  x = nan([1,length(dates),size(dpack{1},3)],class(dpack{1}));
  x(1,lhsindex,:) = dpack{1}(tmp,time,:);
elseif dpack{5}.nametype(nameindex) == 2
  tmp = find(dpack{5}.id{2} == nameindex);
  x = nan([1,length(dates),size(dpack{2},3)],class(dpack{2}));
  x(1,lhsindex,:) = dpack{2}(tmp,time,:);
else
  tmp = find(dpack{5}.id{3} == nameindex);
  x = nan([1,length(dates),size(dpack{3},3)],class(dpack{3}));
  x(1,lhsindex,:) = dpack{3}(tmp,time,:);
end

end % of primary function -----------------------------------------------------------------------------------