function x = precision(x,format)
%
% PRECISION  Convert time series data to single or double precision.
%
% x = precision(x,format)
% Required input arguments:
%   x tseries; format char
%
% The IRIS Toolbox 2007/05/03. Copyright 2007 Jaromir Benes. <a href="www.iris-toolbox.com">www.iris-toolbox.com</a>

% function body ---------------------------------------------------------------------------------------------

switch lower(strtrim(format))
case 'single', x.data = single(x.data);
case 'double', x.data = double(x.data);
otherwise error('Unrecognized precision: ''%s''',format);
end

end % of primary function -----------------------------------------------------------------------------------