function h = ucircle(varargin)

h = plotcircle(0,0,1,varargin{:});
aux = get(gca,'yticklabel');
label = '';
for j = 1 : size(aux,1)
  label = strvcat(label,sprintf('%s i',strtrim(aux(j,:))));
end
set(gca,'yticklabel',strjust(label),'ytickmode','manual');
axis('equal');
axis('square');

end