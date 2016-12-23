function [x,b] = detrend_(x,varargin)
%
% Called from within tseries/detrend.
%
% The IRIS Toolbox 2007/11/23. Copyright 2007 Jaromir Benes. <a href="http://www.iris-toolbox.com">www.iris-toolbox.com</a>
%

% ###########################################################################################################
%% function body

[xtrend,b] = trend_(x,varargin{:});
x = x - xtrend;

end
% end of primary function