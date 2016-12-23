function h = emptygraph();

h = gca;
set(h,'xtick',[],'ytick',[],'xcolor',[1,1,1],'ycolor',[1,1,1],'xlim',[0,1],'ylim',[0,1],'xlimmode','manual','ylimmode','manual','box','on');

end