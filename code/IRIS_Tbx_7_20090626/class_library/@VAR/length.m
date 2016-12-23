function n = length(w)
%
% <a href="matlab: edit VAR/length">LENGTH</a>  Number of alternative parameterisations in VAR object.
%
% Syntax:
%   n = length(w)
% Output arguments.
%   n [ numeric ]  Number of alternative parameterisations.
% Required input arguments:
%   w [ VAR ] VAR object.
%
% The IRIS Toolbox 2007/10/18. Copyright 2007 Jaromir Benes. <a href="http://www.iris-toolbox.com">www.iris-toolbox.com</a>
%

% ###########################################################################################################
%% function body

n = size(w.A,3);

end

% end of primary function
% ###########################################################################################################