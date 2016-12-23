function tickyears(varargin)
% Year-based grid on X axis.

% The IRIS Toolbox 2009/01/30.
% Copyright (c) 2007-2009 Jaromir Benes.

if ~isempty(varargin) && all(ishandle(varargin{1}))
   h = varargin{1};
   varargin(1) = [];
else
   h = gca();
end

if ~isempty(varargin)
   n = varargin{1};
else
   n = 1;
end

%********************************************************************
%! Function body.


for ih = vech(h)
   if ~isempty(getappdata(ih,'plotyy'))
      ih = getappdata(ih,'plotyy');
   end
   xLim = get(ih,'xLim');
   xTick = floor(xLim(1)) : n : ceil(xLim(end));
   xTickLabel = {};
   set(ih,...
      'xLim',xTick([1,end]),...
      'xLimMode','manual',...
      'xTick',xTick,...
      'xTickMode','manual',...
      'xTickLabelMode','auto');
end

end
% End of primary function.