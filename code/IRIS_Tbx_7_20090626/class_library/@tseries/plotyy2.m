function [ax,lhs,rhs,range] = plotyy(varargin)
%
% PLOTYY  Line plot function with LHS and RHS axes for time series.
%
% Syntax:
%   [ax,lhs,rhs,rng] = plotyy(xlhs,xrhs,...)
%   [ax,lhs,rhs,rng] = plotyy(rng,xlhs,xrhs,...)
%   [ax,lhs,rhs,rng] = plotyy(ax,rng,xlhs,xrhs,...)
% Output arguments:
%   ax [ numeric ] Handles to axes.
%   lhs [ numeric ] Handles to LHS lines.
%   rhs [ numeric ] Handles to RHS lines.
%   rng [ numeric ] Time range actually used.
% Required input arguments:
%   rng [ numeric ] Time range, <a href="dates.html">IRIS serial date numbers</a>.
%   xlhs [ tseries ] Time series associated with LHS axis.
%   xrhs [ tseries ] Time series associated with RHS axis.
%   ax [ numeric ] Handle to requested axes.
% <a href="options.html">Optional input arguments:</a>
%   'dateformat' [ char | <a href="default.m">irisget('plotdateformat')</a> ] Date format.
%   'datetick' [ numeric | <a href="default.m">'auto'</a> ] Ticks on horizontal axis.
%   'function' [ function_handle | <a href="default.m">empty</a> ] Function to call at the end with axes handle passed in.
%
% The IRIS Toolbox 4/18/2007. Copyright 2007 Jaromir Benes.
%

plotdateformat = irisget('plotdateformat');

if nargin > 1 && isnumeric(varargin{1}) && isnumeric(varargin{2})
  ax = varargin{1};
  varargin(1) = [];
else
  ax = gca();
end

if isnumeric(varargin{1})
  range = varargin{1};
  varargin(1) = [];
  setxlim = true;
else
  range = Inf;
  setxlim = false;
end

xlhs = varargin{1};
xrhs = varargin{2};
varargin(1:2) = [];

options.dateformat = plotdateformat;
options.datetick = Inf;
if ~isempty(varargin)
  for name = vech(fieldnames(options))
    index = find(strcmpi(name{1},varargin),1,'last');
    if ~isempty(index)
      options.(name{1}) = varargin{index+1};
      varargin([index,index+1]) = [];
    end
  end
end

% ###########################################################################################################
% function body

% check for existing line plots when nextplot is add
isline = false;
add = false;
if strcmp(get(ax,'nextplot'),'add')
  add = true;
  h = get(ax,'children');
  for i = vech(h)
    isline = isline | strcmp(get(i,'type'),'line');
  end
end
% unable to add tseries line(s) to existing non-tseries lines
if isline == true
  tag = get(ax,'tag');
  if ~strcmp(tag,'tseries'), error('Current figure contains non-tseries line(s). Unable to add tseries lines.'); end
  set(ax,'xticklabelmode','auto');
end

xlhs.data = xlhs.data(:,:);
xrhs.data = xrhs.data(:,:);
nlhs = size(xlhs.data,2);
nrhs = size(xrhs.data,2);
[data,range] = getdata_([xlhs,xrhs],range);
datalhs = data(:,1:nlhs);
datarhs = data(:,nlhs+1:end);

if isempty(range)
  [ax,lhs,rhs] = plotyy(ax,0,nan([1,nlhs]),0,nan([1,nrhs]));
  set([lhs;rhs],'xdata',[],'ydata',[]);
  set(ax,'xlim',[0,1],'xtick',0.5);
  set(ax,'xticklabel','NaN');
  return
end

[year,per,freq] = dat2ypf(range);
freq = freq(1);

set(ax,'xtickmode','auto','xticklabelmode','auto');
time = dat2dec(range);
[ax,lhs,rhs] = plotyy(time,datalhs,time,datarhs);
if ~isempty(varargin), set([lhs;rhs],varargin{:}); end

% first tick = start of first year
firsttick = floor(time(1));
% last tick = end of last year
lasttick = ceil(time(end));
if any(freq == [2,4,12]), lasttick = lasttick - 1/freq; end
% fix numerical inaccuracy
if lasttick < time(end), lasttick = time(end); end
set(ax,'xlim',[firsttick,lasttick]);

setdatetick(ax,freq,options.dateformat,options.datetick);
set(ax(2),'xticklabel','');
% adjust xlim if users plot range specified
if ~isnan(freq) && setxlim == true && length(time) > 1
  set(ax,'xlim',[time(1),time(end)],'xlimmode','manual');
end

set(ax,'tag','tseries','userdata',freq);

end

% end of primary function
% ###########################################################################################################