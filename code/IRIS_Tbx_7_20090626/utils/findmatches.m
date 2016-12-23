function [listlogic,patternlogic] = findmatches(list,pattern)
%
% The IRIS Toolbox 2007/05/22. Copyright 2007 <a href="mailto:jaromir.benes@gmail.com?subject=The%20IRIS%20Toolbox%3A%20%5Byour%20subject%5D">Jaromir Benes</a>. <a href="www.iris-toolbox.com">www.iris-toolbox.com</a>

if (~iscellstr(list) && ~ischar(list)) || (~iscellstr(pattern) && ~ischar(pattern))
  error('Incorrect type of input argument(s).');
end

if ischar(list), list = {list}; end
if ischar(pattern), pattern = {pattern}; end

% function body ---------------------------------------------------------------------------------------------

patternlogic = false(size(pattern));
listlogic = false(size(list));

for i = 1 : length(pattern)
  tmp = regexp(list,sprintf('^%s$',pattern{i}),'once');
  tmp = ~cellfun(@isempty,tmp);
  if any(tmp)
    patternlogic(i) = true;
    listlogic(tmp) = true;
  end
end

end % of primary function -----------------------------------------------------------------------------------