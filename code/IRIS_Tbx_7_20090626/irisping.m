function x = irisping()
%
% <a href="matlab: edit irisping">IRISPING</a>  Current version/distribution of IRIS installed on your computer.
%
% Syntax:
%   [msg,d] = irisping()
% Output Arguments:
%   msg [ char ] Screen message.
%   d [ char ] Current version/distribution as character string.
%
% The IRIS Toolbox 2007/10/11. Copyright 2007 Jaromir Benes. <a href="http://www.iris-toolbox.com">www.iris-toolbox.com</a>
%

% ###########################################################################################################
%% function body

x = sprintf('<a href="http://www.iris-toolbox.com">The IRIS Toolbox</a> version %s.',irisversion());

end
% end of primary function