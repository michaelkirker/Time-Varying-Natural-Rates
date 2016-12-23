function x = data(x,matrix,varargin)

if not(iscellstr(varargin(1:2:end)))
  error('Incorrect type of input argument(s).');
end

if nargin < 2, matrix = []; end
if ~isnumeric(matrix), error('Incorrect type of input argument(s).'); end

chksyntax_(x.parenttype{end},'data');
x.contents{end+1} = reportobject_('data',matrix,x.parentoptions{end},varargin{:});

end