function varargout = alternative(varargin)
%
% ALTERNATIVE  Select subset of model parameterizations and respective solutions.
%
% Syntax:
%   n = alternative(m,alt)
% Arguments:
%   n,m model; alt numeric|logical
%
% The IRIS Toolbox 2007/05/03. Copyright 2007 Jaromir Benes. <a href="www.iris-toolbox.com">www.iris-toolbox.com</a>

% function body ---------------------------------------------------------------------------------------------

[varargout{1:nargout}] = fetch(varargin{:});

end % of primary function -----------------------------------------------------------------------------------