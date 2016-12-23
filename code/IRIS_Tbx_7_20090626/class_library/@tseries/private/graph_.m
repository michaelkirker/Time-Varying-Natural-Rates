function [handle,range,data] = graph_(fcn,wide,varargin)
% Called from within tseries/plot and tseries/bar.

% The IRIS Toolbox 2008/09/30.
% Copyright (c) 2007-2008 Jaromir Benes.

if length(varargin) > 2 && isnumeric(varargin{1}) && isnumeric(varargin{2})
   % plot(handle,range,tseries,...)
   ax = varargin{1};
   range = varargin{2};
   varargin(1:2) = [];
elseif length(varargin) > 1 && isnumeric(varargin{1})
   % plot(range,tseries,...)
   ax = gca();
   range = varargin{1};
   varargin(1) = [];
else
   % plot(tseries,...)
   ax = gca();
   range = Inf;
end
userrange = range;

x = varargin{1};
varargin(1) = [];

if ~iscellstr(varargin(1:2:end))
   error('Invalid type of input argument(s).');
end

flag = true;
oldSyntax = false;
try
   if length(varargin) == 1
      [plotspec,options] = oldargin_(varargin{1});
      oldSyntax = true;
   elseif isempty(varargin) || cellfun(@ischar,varargin(1:2:end)) || cellfun(@iscellstr,varargin(1:2:end))
      [options,plotspec] = newargin_(varargin{:});
   else
      flag = false;
   end
catch
   if cellfun('isclass',varargin(1:2:end),'char') | cellfun('isclass',varargin(1:2:end),'cell')
      [options,plotspec] = newargin_(varargin{:});
   else
      flag = false;
   end
end

if ~flag
   error('Incorrect type of input argument(s).');
end

%********************************************************************
%! Function body.

x.data = x.data(:,:);
[nper,nx] = size(x.data);
if all(isinf(range))
   range = x.start + (0 : nper-1);
end

handle = [];
if isempty(range)
   warning('iris:tseries','No graph displayed because date range is empty.');
   return
end

range = range(1) : range(end);
userrange = range;
freq = datfreq(range(1));

% If hold==on, make sure new range comprises existing dates.
if ~isempty(range) && strcmp(get(ax,'nextPlot'),'add')
   xlim = get(ax,'xLim');
   range = mergerange_(range,xlim);
end

% Make sure new range and userrange both comprise options.comprise dates.
% This is used in plotyy.
if ~isempty(options.comprise)
   range = mergerange_(range,options.comprise);
   userrange = mergerange_(userrange,options.comprise);
end

%! Nested function mergerange_()   
function range = mergerange_(range,comprise)
   first = grid2dat(comprise(1),freq);
   while dat2grid(first-1) > comprise(1)
      first = first - 1;
   end
   last = grid2dat(comprise(end),freq);
   while dat2grid(last+1) < comprise(end)
      last = last + 1;
   end
   range = min([range(1),first]) : max([range(end),last]);
end
% End of nested function mergerange_()

data = rangedata(x,range);

set(ax,'xtickmode','auto','xticklabelmode','auto');
time = dat2grid(range);
if oldSyntax
   handle = fcn(ax,time,data,plotspec{:});
else
   handle = fcn(ax,time,data);
   if ~isempty(plotspec)
      set(handle,plotspec{:});
   end
end

if freq > 0
   set(ax,'xLim',time([1,end]),'xLimMode','manual');
   timeline(ax,userrange,freq,options);
else
   if ~all(isinf(userrange))
      set(ax,...
         'xLim',userrange([1,end]),...
         'xLimMode','manual');
   end
   if ~isinf(options.datetick)
      set(ax,...
         'xTick',options.datetick,...
         'xTickMode','manual');
   end
end

% Expand xLim for bar graphs.
if wide > 0
   if freq > 0
      xlim = get(ax,'xLim');
      set(ax,'xLim',xlim + ([-wide,wide]./(freq)));
   else
      xlim = get(ax,'xLim');
      set(ax,'xLim',xlim + [-wide,wide]);
   end      
end

% Perform users function.
if ~isempty(options.function)
   options.function(handle);
end

% Mark the axes for highligh function.
setappdata(ax,'tseries',true);
setappdata(ax,'freq',freq);

end
% End of primary function.

%********************************************************************
%! Subfunction oldargin_().

function [plotspec,options] = oldargin_(plotspec) 
   options.dateformat = irisget('plotdateformat');
   options.datetick = Inf;
   options.function = [];
   options.comprise = [];
   if ischar(plotspec)
      i = find(plotspec == '|',1);
      if ~isempty(i)
         options.dateformat = strtrim(plotspec(i+1:end));
         plotspec = {plotspec(1:i-1)};
      else
         plotspec = {plotspec};
      end
   elseif isa(plotspec,'function_handle')
      options.function = plotspec;
      options.dateformat = strtrim(plotspec(Inf));
      plotspec = {''};
   end
end
% End of subfunction oldargin_().

%********************************************************************
%! Subfunction newargin_().

function [options,varargin] = newargin_(varargin) 
   [options,varargin] = extractopt({'dateformat','datetick','function','comprise'},varargin{:});
   default = {...
      'dateformat',irisget('plotdateformat'),@ischar,...
      'datetick',Inf,@isnumeric,...
      'function',[],@(x) isempty(x) || isa(x,'function_handle'),...
      'comprise',[],@isnumeric,...
      'position','centre',@(x) any(strncmpi(x,{'c','s','e'},1)),...
   };
   options = passvalopt(default,options{:});
end
% End of subfunction newargin_().