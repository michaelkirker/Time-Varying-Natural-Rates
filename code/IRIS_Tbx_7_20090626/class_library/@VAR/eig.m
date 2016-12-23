function eigval = eig(w)
%
% <a href="matlab: edit VAR/eig">EIGVAL</a>  Eigenvalues associated with VAR model.
%
% Syntax:
%   v = eig(w)
% Output arguments:
%   v [ numeric ] Eigenvalues.
% Input arguments:
%   w [ VAR ] VAR model.
%
% The IRIS Toolbox 2007/07/18. Copyright 2007 Jaromir Benes. <a href="http://www.iris-toolbox.com">www.iris-toolbox.com</a>
%

% ###########################################################################################################
%% function body

eigval = w.eigval;

end

% end of primary function
% ###########################################################################################################