function [li,ba,lhs,rhs] = linenline(varargin)
%
% <a href="tseries/linenbar">LINENLINE</a>  Combined LHS and RHS line graph function for time series.
%
% Syntax:
%   [li,ba,lhs,rhs] = linenline(x,y,...)
%   [li,ba,lhs,rhs] = linenline(range,x,y,...)
% Required input arguments:
%   li [ numeric ] Handle(s) to LHS line series.
%   ba [ numeric ] Handle(s) to RHS line series.
%   lhs [ numeric ] Handle to LHS axes.
%   rhs [ numeric ] Handle to RHS axes
%   x [ tseries ] Time series to be plotted on LHS.
%   y [ tseries ] Time series to be plotted on RHS.
% <a href="options.html">Optional input arguments:</a>
%   'highlightcolour' [ numeric | <a href="default.html">[0.9,0.9,0.9]</a>] RGB colour code for highlighted area.
%   'dateformat' [ char | <a href="default.html">'YYYY:P'</a> ] Date format for x-axis tick labels.
%   'highlight' [ numeric | <a href="default.html">empty</a> ] Time range to be highlighted, i.e. <a href="dates.html">IRIS serial date numbers</a>.

% The IRIS Toolbox 2008/09/30.
% Copyright (c) 2007-2008 Jaromir Benes.

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

if isempty(varargin)
  error('Incorrect number of input arguments.');
end
% time series for LHS graph
xline = varargin{1};
varargin(1) = [];
nline = size(xline,2);

if isempty(varargin)
  error('Incorrect number of input arguments.');
end
% times series for RHS graph
xbar = varargin{1};
varargin(1) = [];
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

% =======================================================================================
%! Function body.

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

% shift color order for RHS graph
colours = get(lhs,'ColorOrder');
shift = mod(nline,size(colours,1));
colours = [colours(shift+1:end,:);colours(1:shift,:)];
set(rhs,'ColorOrder',colours,'NextPlot','ReplaceChildren');

% RHS graph
axes(rhs);
ba = line(timescale,bardata,'LineWidth',1);
set(rhs,'yaxislocation','right','xlim',timescale([1,end]),'xtick',get(lhs,'xtick'),'xticklabel',[]); % 
set(rhs,'xtickmode','manual','xlimmode','manual','ytickmode','manual','ylimmode','manual','xticklabelmode','manual');
set(rhs,'NextPlot','Replace');

% LHS graph
axes(lhs);
li = line(userrange,xline,'dateformat',options.dateformat,'datetick',options.datetick);
set(lhs,'Color','None');

% set axes colours according to line colours
if nline > 0
  lhscolour = get(li(1),'Color');
else
  lhscolour = [0,0,1];
end
if nbar > 0
  rhscolour = get(ba(1),'Color');
else
  rhscolour = [1,0,0];
end
set(lhs,'YColor',lhscolour,'box','off');
set(rhs,'YColor',rhscolour,'box','on');

ytick = get(rhs,'YTick');
ylim = get(rhs,'ylim');
if ytick(1) ~= ylim(1)
  ytick = [ylim(1),ytick];
end
if ytick(end) ~= ylim(end)
  ytick = [ytick,ylim(end)];
end
set(rhs,'YTick',ytick);

% equalise the number of lhs and rhs yticks if the difference is 1 or 2
lhsytick = get(lhs,'YTick');
rhsytick = get(rhs,'YTick');
nlhs = length(lhsytick);
nrhs = length(rhsytick);
ndf = abs(nrhs - nlhs);
if nlhs < nrhs && ndf <= 2
  ndown = floor(ndf/2);
  nup = ndf - ndown;
  incr = lhsytick(end) - lhsytick(end-1);
  lhsytick = [lhsytick(1)-(ndown:-1:1)*incr,lhsytick,lhsytick(end)+(1:nup)*incr];
  set(lhs,'ylim',lhsytick([1,end]),'YTick',lhsytick);
elseif nlhs > nrhs && ndf <= 2
  ndown = floor(ndf/2);
  nup = ndf - ndown;
  incr = rhsytick(end) - rhsytick(end-1);
  rhsytick = [rhsytick(1)-(ndown:-1:1)*incr,rhsytick,rhsytick(end)+(1:nup)*incr];
  set(rhs,'YLim',rhsytick([1,end]),'YTick',rhsytick);
end

set(rhs,'Position',get(lhs,'Position'));

set([lhs,rhs],'ActivePositionProperty','Position');

if ~isempty(options.highlight)
  if ~isempty(options.colour)
    highlight(rhs,options.highlight,'colour',options.colour);
  else
    highlight(rhs,options.highlight);
  end
end

% Create an invisible object within LHS and set its DeleteFcn property so to delete RHS
% When a new plot command is called, all LHS objects are delete, and hence also RHS
text('Parent',lhs,'Visible','off','HandleVisibility','on','DeleteFcn',@(x,y) trydelete(rhs));
text('Parent',rhs,'Visible','off','HandleVisibility','on','DeleteFcn',@(x,y) trydelete(lhs));

function trydelete(h)
   try
      delete(h)
   end
end

end
% End of primary function.