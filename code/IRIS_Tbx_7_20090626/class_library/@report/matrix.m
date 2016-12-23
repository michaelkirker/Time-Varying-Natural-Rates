function x = matrix(x,data,varargin)

if not(iscellstr(varargin(1:2:end)))
  error('Incorrect type of input argument(s).');
end

if nargin < 2, data = []; end
if ~isnumeric(data)
  error('Incorrect type of input argument(s).')'
end

chksyntax_(x.parenttype{end},'beginmatrix');
x.contents{end+1} = reportobject_('beginmatrix',NaN,x.parentoptions{end},varargin{:});

aux = x.contents{end}.options;
x.contents{end+1} = reportobject_('data',data,aux);
x.contents{end+1} = reportobject_('colnames',aux.colnames,aux);
x.contents{end+1} = reportobject_('rownames',aux.rownames,aux);
x.contents{end+1} = reportobject_('tag',aux.text,aux);
x.contents{end+1} = reportobject_('endmatrix');

end