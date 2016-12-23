function a = cutsmall(x,varargin)
%
% CUTSMALL  Round off numbers with small deviations from base number.
%
% Syntax:
%   x = cutsmall(x,...)
% Required input arguments:
%   x tseries
% <a href="options.html">Optional input arguments:</a>
%   'base' numeric (0)
%   'tolerance' numeric (getrealsmall())
%
% The IRIS Toolbox 2007/05/03. Copyright 2007 Jaromir Benes. <a href="www.iris-toolbox.com">www.iris-toolbox.com</a>

default = {
  'base',0,...
  'tolerance',getrealsmall(),...
};
options = passopt(default,varargin{1:end});

% function body ---------------------------------------------------------------------------------------------

a = unop_(@cutsmall,x,0,options.tolerance,options.base);

end % of primary function -----------------------------------------------------------------------------------