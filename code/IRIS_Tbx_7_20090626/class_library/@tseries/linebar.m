function [li,ba,lhs,rhs] = linenbar(varargin)
%
% <a href="tseries/linenbar">LINENBAR</a>  Combined line and bar graph function for time series.
%
% Syntax:
%   [li,ba,lhs,rhs] = linenbar(x,y,...)
%   [li,ba,lhs,rhs] = linenbar(range,x,y,...)
% Required input arguments:
%   li [ numeric ] Handle(s) to line series.
%   ba [ numeric ] Handle(s) to bar series.
%   lhs [ numeric ] Handle to LHS axes with line graph.
%   rhs [ numeric ] Handle to RHS axes with bar graph.
%   x [ tseries ] Time series to be plotted as lines (LHS axis).
%   y [ tseries ] Time series to be plotted as bars (RHS axis).
% <a href="options.html">Optional input arguments:</a>
%   'highlightcolour' [ numeric | <a href="default.html">[0.9,0.9,0.9]</a>] RGB colour code for highlighted area.
%   'dateformat' [ char | <a href="default.html">'YYYY:P'</a> ] Date format for x-axis tick labels.
%   'highlight' [ numeric | <a href="default.html">empty</a> ] Time range to be highlighted, i.e. <a href="dates.html">IRIS serial date numbers</a>.
%
% The IRIS Toolbox 2007/09/05. Copyright 2007 Jaromir Benes. <a href="http://www.iris-toolbox.com">www.iris-toolbox.com</a>
%

config = irisconfig();
realsmall = getrealsmall();

if length(varargin{1}) == 1 && ishandle(varargin{1})
  rhs = varargin{1};
  varargin(1) = [];
else
  rhs = gca();
end

if isnumeric(varargin{1})
  userrange = varargin{1};
  varargin(1) = [];
else
  userrange = Inf;
end

% time series for line graph
xline = varargin{1};
varargin(1) = [];
nline = size(xline,2);

% times series for bar graph
% if not available, use xline(1) minus xline(2)
if ~isempty(varargin) && istseries(varargin{1})
  xbar = varargin{1};
  varargin(1) = [];
else
  xbar = xline;
  xbar.data = xbar.data(:,1) - xbar.data(:,2);
end
nbar = size(xbar,2);

[data,range] = getdata_([xline,xbar],userrange);
linedata = data(:,1:nline);
bardata = data(:,nline+1:end);

default = {...
  'colour',[],@(x) ischar(x) || (isnumeric(x) && length(x) == 3),...
  'dateformat',config.plotdateformat,@ischar,...
  'datetick',Inf,@isnumeric,...
  'highlight',[],@isnumeric,...
};
options = passvalopt(default,varargin{:});

% ###########################################################################################################
%% function body

freq = datfreq(range(1));
timescale = dat2dec(range);

% clear axes
cla(rhs);
reset(rhs);
delete(get(rhs,'title'));

% copy rhs to lhs
lhs = copyobj(rhs,get(rhs,'parent'));
set([rhs,lhs],'xlim',timescale([1,end]));
set([rhs,lhs],'xlimmode','manual','xtickmode','manual');

% line graph
li = line(lhs,userrange,xline,'dateformat',options.dateformat,'datetick',options.datetick);
set(lhs,'color','none');

% bar graph
barcolour = 0.7*[1,1,1]; % [1,0.6,0.6];
ba = bar(rhs,timescale,bardata,'edgecolor','none','FaceColor',barcolour,'barwidth',0.5);
set(get(ba,'baseline'),'linewidth',0.5,'color',barcolour);
set(rhs,'yaxislocation','right','xlim',timescale([1,end]),'xtick',get(lhs,'xtick'),'xticklabel',[]);
set(rhs,'xtickmode','manual','xlimmode','manual','ytickmode','manual','ylimmode','manual','xticklabelmode','manual');

%{
% set axes colours according to line colours
if ~isempty(li)
  lhscolour = get(li(1),'Color');
else
  lhscolour = [0,0,1];
end
if ~isempty(ba)
  rhscolour = get(ba(1),'FaceColor');
else
  rhscolour = [1,0,0];
end
set(lhs,'YColor',lhscolour,'box','off');
set(rhs,'YColor',rhscolour,'box','on');
%}

ytick = get(rhs,'ytick');
ylim = get(rhs,'ylim');
if ytick(1) ~= ylim(1)
  ytick = [ylim(1),ytick];
end
if ytick(end) ~= ylim(end)
  ytick = [ytick,ylim(end)];
end
set(rhs,'ytick',ytick);

% try to equalise the number of lhs and rhs yticks if the difference is 1 or 2
lhsytick = get(lhs,'ytick');
rhsytick = get(rhs,'ytick');
nlhs = length(lhsytick);
nrhs = length(rhsytick);
ndf = abs(nrhs - nlhs);
if nlhs < nrhs && ndf <= 2
  ndown = floor(ndf/2);
  nup = ndf - ndown;
  incr = lhsytick(end) - lhsytick(end-1);
  lhsytick = [lhsytick(1)-(ndown:-1:1)*incr,lhsytick,lhsytick(end)+(1:nup)*incr];
  set(lhs,'ylim',lhsytick([1,end]),'ytick',lhsytick);
elseif nlhs > nrhs && ndf <= 2
  ndown = floor(ndf/2);
  nup = ndf - ndown;
  incr = rhsytick(end) - rhsytick(end-1);
  rhsytick = [rhsytick(1)-(ndown:-1:1)*incr,rhsytick,rhsytick(end)+(1:nup)*incr];
  set(rhs,'ylim',rhsytick([1,end]),'ytick',rhsytick);
end

% link LHS and RHS axes properites
linkprop([lhs,rhs],{'Position','ActivePositionProperty','Units'});

if ~isempty(options.highlight)
  if ~isempty(options.colour)
    highlight(rhs,options.highlight,'colour',options.colour);
  else
    highlight(rhs,options.highlight);
  end
end

% Create an invisible object within RHS and set its DeleteFcn property so to delete LHS (and vice versa)
% When a new plot command is called, all RHS objects are delete, and hence also LHS
text('Parent',rhs,'Visible','off','HandleVisibility','off','DeleteFcn',@(x,y) trydelete(lhs));
text('Parent',lhs,'Visible','off','HandleVisibility','off','DeleteFcn',@(x,y) trydelete(rhs));

  function trydelete(h)
  try, delete(h), end
  end

end

% end of primary function
% ###########################################################################################################