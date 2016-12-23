function x = title(x,text,varargin)

if not(iscellstr(varargin(1:2:end)))
  error('Incorrect type of input argument(s).');
end

if nargin < 2, text = ''; end
if ~ischar(text)
  error('Incorrect type of input argument(s).')'
end

chksyntax_(x.parenttype{end},'title');
x.contents{end+1} = reportobject_('title',text,x.parentoptions{end},'fontsize','large','bold',true,varargin{:});

end