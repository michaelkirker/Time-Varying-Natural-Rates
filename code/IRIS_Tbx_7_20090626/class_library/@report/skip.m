function x = skip(x,spec)

if nargin < 2, spec = 'med'; end

if ~ischar(spec)
  error('Incorrect type of input argument(s).');
end

chksyntax_(x.parenttype{end},'skip');
x.contents{end+1} = reportobject_('skip',spec);

end