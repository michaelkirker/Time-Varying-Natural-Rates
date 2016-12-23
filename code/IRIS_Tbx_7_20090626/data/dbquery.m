function [list0,list,expr] = dbquery(dbase0,namemask,exprmask,classfilter,namefilter,namelist)
%
% DBQUERY  Database query.
%
% The IRIS Toolbox 2007/05/03. Copyright 2007 Jaromir Benes. <a href="www.iris-toolbox.com">www.iris-toolbox.com</a>

% function body ---------------------------------------------------------------------------------------------

try, dbase0 = rmfield(dbase0,'IRIS_DATABASE'); catch, end

% name filter

if iscellstr(namefilter) && isempty(namelist), namelist = namefilter; end

field = vech(fieldnames(dbase0));
if ischar(namefilter) && ~isempty(namefilter)
  [list0,ans,tokens] = query(field,namefilter);
elseif iscellstr(namelist) & ~isempty(namelist)
  list0 = namelist;
  tokens = cell(size(list0));
  [tokens{:}] = deal(cell([1,0]));
elseif isnumeric(namefilter) && isinf(namefilter)
  list0 = field;
  tokens = cell(size(list0));
  [tokens{:}] = deal(cell([1,0]));
else
  list0 = {};
  tokens = cell(size(list0));
  [tokens{:}] = deal(cell([1,0]));
end

% class filter

if ~(isnumeric(classfilter) && isinf(classfilter))
  classlist = {};
  for i = 1 : length(list0)
    classlist{end+1} = class(dbase0.(list0{i}));
  end
  [ans,index] = query(classlist,classfilter);
  list0 = list0(index);
  tokens = tokens(index);
end

% new names

if nargout > 1
  if ~isempty(namemask)
    list = {};
    for i = 1 : length(list0)
      list{end+1} = unmask_(namemask,list0{i},tokens{i}{:});
    end
  else
    list(1:length(list0)) = {''};
  end
end

% expressions

if nargout > 2
  if ~isempty(exprmask)
    expr = {};
    for i = 1 : length(list0)
      expr{end+1} = unmask_(exprmask,list0{i},tokens{i}{:});
    end
  else
    expr(1:length(list0)) = {''};
  end
end

end % of primary function -----------------------------------------------------------------------------------

  function unmask = unmask_(mask,varargin) % subfunction ----------------------------------------------------

  if isempty(mask)
    unmask = '';
  else
    unmask = mask;
    for i = 1 : nargin-1
      unmask = strrep(unmask,sprintf('@lower($%g)',i-1),lower(varargin{i}));
      unmask = strrep(unmask,sprintf('@upper($%g)',i-1),upper(varargin{i}));
      unmask = strrep(unmask,sprintf('$%g',i-1),varargin{i});
    end
    unmask = regexprep(unmask,'\$\d*','');
  end

  end % of subfunction --------------------------------------------------------------------------------------