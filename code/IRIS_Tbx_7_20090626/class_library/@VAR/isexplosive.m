function flag = isexplosive(this,varargin)
%
% ISEXPLOSIVE  True if any VAR eigenvalue is outside unit circle.
%
% Syntax:
%   flag = isexplosive(this)
% Output arguments:
%   flag [ logical ] True if any VAR eigenvalue is outside unit circle.
% Required input arguments:
%   this [ VAR ] VAR model.
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

flag = vech(any(abs(this.eigval) > 1+options.tolerance,2));

end

% end of primary function
% ###########################################################################################################