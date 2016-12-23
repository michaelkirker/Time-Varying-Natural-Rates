function x = rownames(x,list,varargin)

if not(iscellstr(varargin(1:2:end)))
  error('Incorrect type of input argument(s).');
end

if nargin < 2, list = {};
  elseif ischar(list), list = {list}; end
if ~iscellstr(list), error('Incorrect type of input argument(s).'); end
list = vech(list);

chksyntax_(x.parenttype{end},'rownames');
x.contents{end+1} = reportobject_('rownames',list,x.parentoptions{end},varargin{:});

end