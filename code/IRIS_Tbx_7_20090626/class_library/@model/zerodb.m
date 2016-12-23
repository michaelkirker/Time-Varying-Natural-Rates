function d = zerodb(m,range,varargin)
% To get help for this IRIS function
% * type <a href="matlab: idoc model.zerodb">idoc model.zerodb</a>, or
% * open <a href="matlab: helpbrowser">Matlab Product Help</a> and go the The IRIS Toolbox at the bottom of the Contents pane,

% The IRIS Toolbox 2009/02/20.
% Copyright (c) 2007-2009 Jaromir Benes.

%********************************************************************
%! Function body.

d = sourcedb_(m,range,varargin{:},'deviation',true);

end
% End of primary function.