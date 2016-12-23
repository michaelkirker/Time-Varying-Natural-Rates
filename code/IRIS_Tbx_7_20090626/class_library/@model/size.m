function varargout = size(m)
% To get help for this IRIS function
% * type <a href="matlab: idoc model.size">idoc model.size</a>, or
% * open <a href="matlab: helpbrowser">Matlab Product Help</a> and go the The IRIS Toolbox at the bottom of the Contents pane,

% The IRIS Toolbox 2009/02/13.
% Copyright 2007-2009 Jaromir Benes.

%********************************************************************
%! Function body.

[varargout{1:7}] = size_(m);
if nargout <= 1
   varargout(1:6) = [];
   varargout{1} = [1,varargout{1}];
end

end
% End of primary function.
