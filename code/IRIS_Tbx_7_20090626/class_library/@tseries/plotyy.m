function [ax,hl,hr] = plotyy(varargin)
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

% The IRIS Toolbox 2009/05/19.
% Copyright (c) 2007-2008 Jaromir Benes.

% Handle to axes.
if length(varargin) > 1 && isnumeric(varargin{1}) && isnumeric(varargin{2}) && length(varargin{1}) == 1 && ishandle(varargin{1})
   ax = varargin{1};
   if length(ax) > 1
      ax = ax(1);
   end   
   varargin(1) = [];
else
  ax = gca();
end

% Range for LHS time series.
if isnumeric(varargin{1})
   rangel = varargin{1};
   varargin(1) = [];
else
   rangel = Inf;
end

% LHS time series.
xl = varargin{1};
nxl = size(xl.data(:,:),2);
varargin(1) = [];

% Range for RHS time series.
if isnumeric(varargin{1})
   ranger = varargin{1};
   varargin(1) = [];
else
   ranger = rangel;
end

% RHS time series.
xr = varargin{1};
nxr = size(xr.data(:,:),2);
varargin(1) = [];

[options,varargin] = extractopt({'highlight'},varargin{:});
default = {...
   'highlight',[],@isnumeric,...
};
options = passvalopt(default,options{:});

%********************************************************************
%! Function body.

% Check consistency of ranges and time series.
% LHS.
if ~all(isinf(rangel)) && ~isempty(rangel)
   if datfreq(rangel(1)) ~= get(xl,'freq')
      error('LHS range and LHS time series must have the same periodicity.');
   end
end
% RHS.
if ~all(isinf(ranger)) && ~isempty(ranger)
   if datfreq(ranger(1)) ~= get(xr,'freq')
      error('RHS range and RHS time series must have the same periodicity.');
   end
end

% Clear RHS axes.
cla(ax);
try
   reset(ax);
catch
   ax = gca();
end
delete(get(ax,'title'));

% Shift color order for RHS graph.
col = get(ax,'colorOrder');
shift = mod(nxl,size(col,1));
set(ax,'colorOrder',[col(shift+1:end,:);col(1:shift,:)],'nextPlot','replaceChildren');

% Plot RHS graph.
hr = graph_(@plot,0,ax,ranger,xr,varargin{:});

% Create LHS axes as a copy of RHS axes.
ax = [copyobj(ax(1),get(ax(1),'parent')),ax];
set(ax(1),'colorOrder',col);

% Plot LHS graph. Note that nextPlot is set to replaceChildren.
hl = graph_(@plot,0,ax(1),rangel,xl,varargin{:},'comprise',get(ax(2),'xLim'));

% Copy X-axis properties from LHS to RHS, and link some of them.
list = {'xLim','xTick','xTickLabel'};
for i = 1 : length(list)
   set(ax(2),list{i},get(ax(1),list{i}));
end
hlink = linkprop(ax,{'xLim','xTick'});
setappdata(ax(1),'linkprop',hlink);
setappdata(ax(2),'linkprop',hlink);

% Point to RHS axes. Used in tickyears().
setappdata(ax(1),'plotyy',ax(2));
setappdata(ax(2),'plotyy',ax(2));

% Turn off visibility of LHS X-axis.
set(ax(1),'color','none','box','off','xTickLabel',{});
set(ax(2),'box','on');
set(ax(2),'yAxisLocation','right','nextPlot','replace');
set(ax(2),'Position',get(ax(1),'Position'));
set(ax,'ActivePositionProperty','Position');

% Color axes according to first item in colorOrder.
tmp = get(ax(1),'colorOrder');
set(ax(1),'yColor',tmp(1,:));
tmp = get(ax(2),'colorOrder');
set(ax(2),'yColor',tmp(1,:));

if ~isempty(options.highlight)
   highlight(ax(2),options.highlight);
end

% Create an invisible object within LHS and set its DeleteFcn property so to delete RHS
% When a new plot command is called, all LHS objects are delete, and hence also RHS
text('parent',ax(1),'visible','off','handleVisibility','on','deleteFcn',@(x,y) trydelete_(ax(2)));
text('parent',ax(2),'visible','off','handleVisibility','on','deleteFcn',@(x,y) trydelete_(ax(1)));

%********************************************************************
%! Nested function trydelete_().
   function trydelete_(h)
      try
         delete(h)
      end
   end
% End of nested function trydelete_().

end
% End of primary function.