function a = len(x)
%
% LEN  Length of time series.
%
% Syntax:
%   x = len(u)
% Required input arguments:
%   x: numeric, u: tseries
%
% The IRIS Toolbox 2007/05/03. Copyright 2007 Jaromir Benes. <a href="www.iris-toolbox.com">www.iris-toolbox.com</a>

% function body ---------------------------------------------------------------------------------------------

a = size(x.data,1);

end % of primary function -----------------------------------------------------------------------------------