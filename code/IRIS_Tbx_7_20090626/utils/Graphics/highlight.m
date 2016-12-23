function h = highlight(varargin)
% <a href="matlab: edit highlight">HIGHLIGHT</a>  Highlight specific time range in time series graph.
%
% Syntax:
%   h = highlight(range,...)      (1)
%   h = highlight(ax,range,...)   (2)
% Output arguments:
%   h [ numeric ] Handle to highlighted area.
% Required input arguments:
%   range [ numeric ] Time range to be highlighted, i.e. <a href="dates.html">IRIS serial date numbers</a>.
% Required input arguments for syntax (2):
%   ax [ numeric ] Handle(s) to axes where the highlight will be added.
% <a href="options.html">Optional input arguments:</a>
%   'colour' [ numeric | <a href="default.html">[0.9,0.9,0.9]</a> ] RGB colour code.
%   'bar' [ true | <a href="default.html">false</a> ] The edges of the highlight area lie between two dates for bar graphs.

% The IRIS Toolbox 2009/03/17.
% Copyright 2007-2009 Jaromir Benes.

if all(ishandle(varargin{1}))
   h = varargin{1};
   varargin(1) = [];
elseif iscell(varargin{1})
   h = [varargin{1}{:}];
   varargin(1) = [];
else
   h = gca();
end

range = varargin{1};
varargin(1) = [];

default = {...
   'grade',[],@(x) isnumeric(x) && length(x) <= 1,...
   'colour',0.8*[1,1,1],@(x) (isnumeric(x) && length(x) == 3) || ischar(x),...
   'color',[],@(x) isempty(x) || (isnumeric(x) && length(x) == 3) || ischar(x),...
   'bar',false,@islogical,...
};
options = passvalopt(default,varargin{:});

if ~isempty(options.color)
   options.colour = options.color;
end

if ~isempty(options.grade)
   options.colour = options.grade*[1,1,1];
end

%********************************************************************
%! Function body.

for hi = vech(h)

   % Preserve the order of figure children.
   fi = get(hi,'parent');
   fich = get(fi,'children');
   visible = get(fi,'visible');
   
   % Axes to be on top of lines and patches.
   set(hi,'layer','top');
   flag = getappdata(hi,'tseries');
   if ~isempty(flag) && flag
      range = range(1) : range(end);
      freq = datfreq(range(1));
      timescale = dat2grid(range);
      if isempty(timescale)
         continue
      end
      if freq > 0
         around = 1/(2*freq);
      else
         around = 0.5;
      end
      timescale = [timescale(1)-around,timescale(end)+around];
   else
      timescale = range;
   end
   
   ylim = get(hi,'ylim');
   y = ylim([1,1,2,2]);
   x = timescale([1,end,end,1]);
   axes(hi);
   % [axes] makes children and parent always visible.
   % Make parent figure invisible if it was before.
   set(fi,'visible',visible);
   g = patch(x,y,options.colour);
   set(g,'edgecolor','none');
   set(hi,'ylimmode','manual');
   set(hi,'ylim',ylim);
   
   % Order patch last.
   ch = get(hi,'children');
   index = find(ch == g);
   ch(index) = [];
   ch(end+1) = g;
   set(hi,'children',ch);
   
   % Reset the order of figure children.
   set(fi,'children',fich);

end

end
% End of primary function.