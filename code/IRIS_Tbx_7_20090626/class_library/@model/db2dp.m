function varargout = db2dp(this,varargin)
% To get help for this IRIS function
% * type <a href="matlab: idoc model.db2dp">idoc model.db2dp</a>, or
% * open <a href="matlab: helpbrowser">Matlab Product Help</a> and go the The IRIS Toolbox at the bottom of the Contents pane,

% The IRIS Toolbox 2008/10/03.
% Copyright (c) 2007-2008 Jaromir Benes.

% =======================================================================================
%! Function body.

[varargout{1:nargout}] = db2dp(meta(this,false),varargin{:});

end
% End of primary function.