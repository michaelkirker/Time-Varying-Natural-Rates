function x = row(x,series,varargin)

if not(iscellstr(varargin(1:2:end)))
  error('Incorrect type of input argument(s).');
end

if nargin < 2, series = tseries(); end
if ~istseries(series)
  error('Incorrect type of input argument(s).')'
end

chksyntax_(x.parenttype{end},'row');
x.contents{end+1} = reportobject_('row',series,x.parentoptions{end},'sstate',NaN,varargin{:});

end