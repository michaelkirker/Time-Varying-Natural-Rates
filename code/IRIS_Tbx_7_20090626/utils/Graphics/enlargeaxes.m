function enlargeaxes(h,event)

% called from within a child
if ~strcmp(get(h,'Type'),'axes')
  h = get(h,'Parent');
end

% parent figure
holdfig = get(h,'Parent');

% possible legends associated with h
holdleg = [];
for i = vech(findobj(get(holdfig,'Children'),'Type','axes','Tag','legend'))
  aux = get(i,'UserData');
  if aux.PlotHandle == h
    holdleg(end+1) = i;
  end
end

% must be double click
if ~strcmp(get(holdfig,'SelectionType'),'open')
  return
end

% copy and clear parent figure
hnewfig = copyobj(holdfig,0);
clf(hnewfig);

% copy and enlarge axes
hnew = copyobj(h,hnewfig);
set(hnew,'ButtonDownFcn',[],'Units','Normalized','Position',[0.1300,0.1100,0.7750,0.8150]);

% copy legend
hnewleg = copyobj(holdleg,hnewfig);
set(hnewleg,'Location','Best');

end