function [li,lhs] = line(varargin)
%
% <a href="tseries/linenbar">LINE</a>  Line graph function for time series.
%
% Syntax:
%   [li,lhs] = line(x,...)
%   [li,lhs] = line(range,x,...)
% Required input arguments:
%   li [ numeric ] Handle(s) to line series.
%   lhs [ numeric ] Handle to axes with graph.
%   x [ tseries ] Time series to be plotted.
% <a href="options.html">Optional input arguments:</a>
%   'highlightcolour' [ numeric | <a href="default.html">[0.9,0.9,0.9]</a>] RGB colour code for highlighted area.
%   'dateformat' [ char | <a href="default.html">'YYYY:P'</a> ] Date format for x-axis tick labels.
%   'highlight' [ numeric | <a href="default.html">empty</a> ] Time range to be highlighted, i.e. <a href="dates.html">IRIS serial date numbers</a>.
%
% The IRIS Toolbox 2007/06/30. Copyright 2007 Jaromir Benes. <a href="http://www.iris-toolbox.com">www.iris-toolbox.com</a>

config = irisconfig();
realsmall = getrealsmall();

if length(varargin{1}) == 1 && ishandle(varargin{1})
  lhs = varargin{1};
  varargin(1) = [];
else
  lhs = gca();
end

if isnumeric(varargin{1})
  userrange = varargin{1};
  varargin(1) = [];
  if length(userrange) == 1 && isinf(userrange)
    userrange = [-Inf,Inf];
  end
else
  userrange = [-Inf,Inf];
end

% time series for line graph
xline = varargin{1};
varargin(1) = [];
[data,range] = getdata_(xline,userrange);

default = {...
  'colour',[],...
  'dateformat',config.plotdateformat,...
  'datetick',Inf,...
  'highlight',[]};
options = passopt(default,varargin{:});

% function body ---------------------------------------------------------------------------------------------

freq = datfreq(range(1));
timescale = dat2dec(range);

set(lhs,'xlim',timescale([1,end]),'ticklength',[0,0]);
set(lhs,'xlimmode','manual','xtickmode','manual');

% clear axes
cla(lhs);
delete(get(lhs,'title'));

% line graph
li = plot(lhs,timescale,data,'linewidth',1);
set(lhs,'xlim',timescale([1,end]));

% set date tick labels
xtick = get(lhs,'xtick');
% remove ticks that do not exactly correspond to periods
aux = freq*(xtick - floor(xtick));
xtick(abs(aux - round(aux)) > realsmall) = [];
xticklabel = dat2str(dec2dat(xtick,freq),'dateformat',options.dateformat);
set(lhs,'xtick',xtick,'xticklabel',xticklabel);

ytick = get(lhs,'ytick');
ylim = get(lhs,'ylim');
if ytick(1) ~= ylim(1)
  ytick = [ylim(1),ytick];
end
if ytick(end) ~= ylim(end)
  ytick = [ytick,ylim(end)];
end
set(lhs,'ytick',ytick);

% fix ticks and labels
set(lhs,'xtickmode','manual','xlimmode','manual','ytickmode','manual','ylimmode','manual','xticklabelmode','manual');

set(lhs,'activepositionproperty','position');

if ~isempty(options.highlight)
  if ~isempty(options.colour)
    highlight(lhs,options.highlight,'colour',options.colour);
  else
    highlight(lhs,options.highlight);
  end
end

end % of primary function -----------------------------------------------------------------------------------