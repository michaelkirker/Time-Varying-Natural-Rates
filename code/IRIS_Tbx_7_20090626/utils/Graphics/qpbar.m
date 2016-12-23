function h = qpbar(range,x,xlegend,varargin)
% Called from within qplot.

% The IRIS Toolbox 2008/02/27.
% Copyright (c) 2007-2008 Jaromir Benes.

default = {...
   'dateformat','YYYY:P',@ischar,...
   'grid',true,@islogical,...
   'highlight',[],@isnumeric,...
   'tight',false,@islogical,...
};
options = passvalopt(default,varargin{:});

% ===========================================================================================================
%! function body 

if ~any(cellfun(@istseries,x))
  return
end

h = bar(range,[x{:}],'dateformat',options.dateformat);

if options.tight
   axis('tight');
end

if any(~cellfun(@isempty,xlegend))
  legend(xlegend{:},'Location','Best');
end

if options.grid
   grid('on');
end

if ~isempty(options.highlight)
   highlight(options.highlight,'bar',true);
end

end
% end of primary function
