function eigval = eig(this,alt)
%
% To get help for this IRIS function
% * type <a href="matlab: idoc model.eig">idoc model.eig</a>, or
% * open <a href="matlab: helpbrowser">Matlab Product Help</a> and go the The IRIS Toolbox at the bottom of the Contents pane,
%
% The IRIS Toolbox 2008/05/05. Copyright 2007-2008 Jaromir Benes. <a href="http://www.iris-toolbox.com">www.iris-toolbox.com</a>

if nargin < 2
  alt = Inf;
end

% ###########################################################################################################
%% function body

if any(isinf(alt))
  alt = 1 : size(this.assign,3);
else
  alt = vech(alt);
end

eigval = this.eigval(1,:,alt);

% solution not available for some parameterisations
[flag,nansolution] = isnan(this,'solution');
if flag
  warning_(44,sprintf(' %g',find(nansolution)));
end

end
% end of primary function
