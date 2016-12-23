function [index,notfound] = findnames(list,selection)
% FINDNAMES  Find positions of entries in a list.
%
% Syntax:
%   [index,notfound] = findnames(list,selection)
% Output arguments:
%   index [ numeric ] Positions of items in list. NaN if not found.
%   notfound [ cellstr ] Items not found in list.
% Required input arguments:
%   list [ cellstr ] List of items to be searched.
%   selection [ cellstr | char ] List of items to be found.

% The IRIS Toolbox 2009/04/28.
% Copyright 2007-2009 Jaromir Benes.

if (~iscell(list) && ~ischar(list)) || (~iscell(selection) && ~ischar(selection))
  error('Incorrect type of input argument(s).');
end

if ischar(selection)
  selection = {selection};
end

%********************************************************************
%! Function body.

index = nan(size(selection));
for i = 1 : length(selection(:))
   tmp = strcmp(list,selection{i});
   if any(tmp)
      index(i) = find(tmp,1);
   end
end
notfound = vech(selection(isnan(index)));

end
%% End of primary function.