function tag(text,href)
if nargin < 2
   href = '';
end
disp(sprintf('<a href="%s">%s</a>',href,text));
end