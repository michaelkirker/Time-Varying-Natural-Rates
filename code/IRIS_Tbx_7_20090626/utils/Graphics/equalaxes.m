function equalaxes(h)

xmin = Inf;
xmax = -Inf;
ymin = Inf;
ymax = -Inf;
for i = vech(h)
   for j = vech(findobj(i,'type','line'))
      xmin = min([xmin,min(get(j,'xdata'))]);
      xmax = max([xmax,max(get(j,'xdata'))]);
      ymin = min([ymin,min(get(j,'ydata'))]);
      ymax = max([ymax,max(get(j,'ydata'))]);
   end
   %{
   xlim = get(i,'xlim');
   ylim = get(i,'ylim');
   xmin = min([xmin,xlim(1)]);
   xmax = max([xmax,xlim(2)]);
   ymin = min([ymin,ylim(1)]);
   ymax = max([ymax,ylim(2)]);
   %}
end
linkaxes(h);
set(h,'xlim',[xmin,xmax],'ylim',[ymin,ymax]);

end