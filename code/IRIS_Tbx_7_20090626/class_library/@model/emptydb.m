function d = emptydb(this)
%
% To get help for this IRIS function
% * type <a href="matlab: idoc model.emptydb">idoc model.emptydb</a>, or
% * open <a href="matlab: helpbrowser">Matlab Product Help</a> and go the The IRIS Toolbox at the bottom of the Contents pane,
%
% The IRIS Toolbox 2008/05/05. Copyright 2007-2008 Jaromir Benes. <a href="http://www.iris-toolbox.com">www.iris-toolbox.com</a>

% ###########################################################################################################
% function body

x(1:sum(this.nametype <= 3)) = {tseries()};
x(end+(1:sum(this.nametype == 4))) = {[]};
d = cell2struct(x,this.name,2);

end
% end of primary function