function flag = issolved(m)
% To get help for this IRIS function
% * type <a href="matlab: idoc model.issolved">idoc model.issolved</a>, or
% * open <a href="matlab: helpbrowser">Matlab Product Help</a> and browse The IRIS Toolbox documentation in the Contents pane.

% The IRIS Toolbox 2009/01/27.
% Copyright 2007-2009 Jaromir Benes.

%********************************************************************
%! Function body.

[ans,flag] = isnan(m,'solution');
flag = ~flag;

end
% End of primary function.