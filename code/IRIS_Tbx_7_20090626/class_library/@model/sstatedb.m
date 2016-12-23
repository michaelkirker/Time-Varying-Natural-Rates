function d = sstatedb(m,range,varargin)
% To get help for this IRIS function
% * type <a href="matlab: idoc model.sstatedb">idoc model.sstatedb</a>, or
% * open <a href="matlab: helpbrowser">Matlab Product Help</a> and go the The IRIS Toolbox at the bottom of the Contents pane,

% The IRIS Toolbox 2009/02/20.
% Copyright 2007-2009 Jaromir Benes.

%********************************************************************
%! Function body.

d = sourcedb_(m,range,varargin{:},'deviation',false);

end
% End of primary function.