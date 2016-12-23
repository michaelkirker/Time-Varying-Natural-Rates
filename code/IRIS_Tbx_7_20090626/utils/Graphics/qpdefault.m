function [h,range,data] = qpdefault(range,x,type,legendfcn,varargin)
% <a href="matlab: edit utils/graphics/qpdefault">UTILS/GRAPHICS/QPDEFAULT</a>  Called from within qplot.

% The IRIS Toolbox 2009/05/06.
% Copyright (c) 2007-2009 Jaromir Benes.

[options,varargin] = extractopt({'grid','highlight','tight'},varargin{:});
default = {...
   'grid',true,@islogical,...
   'highlight',[],@isnumeric,...
   'tight',false,@islogical,...
};
options = passvalopt(default,options{:});

%********************************************************************
%! Function body.

nx = length(x);

switch type
case 'line'
   data = [x{:}];
   if istseries(data)
      [h,range,data] = plot(range,data,varargin{:});
   else
      h = plot(range,data,varargin{:});
   end
case 'bar'
   data = [x{:}];
   if istseries(data)
      [h,range,data] = bar(range,[x{:}],varargin{:});
   else
      h = plot(range,data,varargin{:});
   end
end

a = gca();

if options.tight
   axis('tight');
end

if options.grid
   grid('on');
end

tmplegend = legendfcn();
% Display legend if there is at least one non-empty entry.
if any(~cellfun(@isempty,tmplegend))
   legend(tmplegend{:},'Location','Best');
end

if ~isempty(options.highlight)
   highlight(options.highlight);
end

end
% End of primary function.
