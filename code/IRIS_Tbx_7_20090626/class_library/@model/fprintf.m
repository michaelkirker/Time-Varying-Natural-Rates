function fprintf(m,fname,varargin)
%
% To get help for this IRIS function
% * type <a href="matlab: idoc model.fprintf">idoc model.fprintf</a>, or
% * open <a href="matlab: helpbrowser">Matlab Product Help</a> and go the The IRIS Toolbox at the bottom of the Contents pane,

% The IRIS Toolbox 2008/08/31.
% Copyright (c) 2007-2008 Jaromir Benes.

% ===========================================================================================================
%! function body

if ismodel(fname)
   [m,fname] = deal(fname,m);
end

s = sprintf(m,varargin{:});
char2file(s,fname);

end
% end of primary function