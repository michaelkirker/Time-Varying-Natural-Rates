function x = paragraph(x,text,varargin)

if not(iscellstr(varargin(1:2:end)))
  error('Incorrect type of input argument(s).');
end

if nargin < 2, text = ''; end
if ~ischar(text)
  error('Incorrect type of input argument(s).')'
end

chksyntax_(x.parenttype{end},'paragraph');
x.contents{end+1} = reportobject_('paragraph',text,x.parentoptions{end},varargin{:});

end