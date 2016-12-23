function x = newpage(x)

chksyntax_(x.parenttype{end},'newpage');
x.contents{end+1} = reportobject_('newpage');

end