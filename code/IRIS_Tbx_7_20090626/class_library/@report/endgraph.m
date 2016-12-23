function x = endgraph(x)
% ENDGRAPH  Finish graph and close Matlab figure.
%
% Syntax:
%   p = endgraph(p)
% Required input arguments:
%   p report

% The IRIS Toolbox 2009/03/30.
% Copyright 2007-2009 Jaromir Benes.

%********************************************************************
%! Function body.

config = irisconfig();

chksyntax_(x.parenttype{end},'endgraph');
% Apply dateformat if graph contains tseries.
ch = vech(get(x.parentspec{end},'children'));
tmpType = get(ch,'type');
if iscellstr(tmpType)
   tmpType = vech(tmpType);
end
index = strcmp(tmpType,'axes');
for i = ch(index)
  if strcmp(get(i,'tag'),'tseries')
    freq = get(i,'userdata');
    xtick = get(i,'xtick');
    xticklabel = get(i,'xticklabel');
    dateformat = iff(any(isinf(x.parentoptions{end}.dateformat)),config.plotdateformat,x.parentoptions{end}.dateformat);
    set(i,'xticklabel',dat2char(dec2dat(xtick,freq),'dateformat',dateformat));
  end
end

if ~isempty(x.parentoptions{end}.saveas)
  fname = x.parentoptions{end}.saveas;
else
  [aux,fname] = fileparts(tempname);
end
fname = sprintf('%s.eps',fname);

device = iff(x.parentoptions{end}.color,'-depsc','-deps');
% figure(x.parentspec{end});
print(device,fname);

spec = {fname,file2char(fname)};
delete(fname);

if x.parentoptions{end}.close, close(x.parentspec{end}); end

x.contents{end+1} = reportobject_('endgraph',spec);
x.parenttype = x.parenttype(1:end-1);
x.parentoptions = x.parentoptions(1:end-1);
x.parentspec = x.parentspec(1:end-1);

end % of primary function -----------------------------------------------------------------------------------