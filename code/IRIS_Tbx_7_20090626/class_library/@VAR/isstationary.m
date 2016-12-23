function flag = isstationary(w,varargin)
%
% ISSTATIONARY  True if all VAR eigenvalues are within unit circle.
%
% Syntax:
%   flag = isstationary(w)
% Output arguments:
%   flag [ logical ] True if all VAR eigenvalues are within unit circle.
% Required input arguments:
%   w [ VAR ] VAR model.
% <a href="options.html">Optional input arguments:</a>
%   'tolerance' [ numeric | getrealsmall() ] Numerical tolerance for eigenvalue test.
%
% The IRIS Toolbox 2007/05/03. Copyright 2007 Jaromir Benes. <a href="www.iris-toolbox.com">www.iris-toolbox.com</a>
%

default = {...
  'tolerance',getrealsmall(),...
};
options = passopt(default,varargin{:});

% ###########################################################################################################
%% function body

flag = vech(all(abs(w.eigval) <= 1-options.tolerance,2));

end

% end of primary function
% ###########################################################################################################