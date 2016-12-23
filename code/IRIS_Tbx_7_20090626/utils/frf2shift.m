function [rad,per] = frf2shift(F,varargin)
%
% FRF2SHIFT  Phase shift of frequence response function.
%
% Syntax:
%   [rad,per] = frf2shift(F)
% Output arguments:
%   radian [ numeric ] Phase shift in radians.
%   period [ numeric ] Phase shift in periods.
% Required input arguments:
%   F [ numeric ] Frequency response function.
%
% The IRIS Toolbox 2007/05/03. Copyright 2007 Jaromir Benes. <a href="www.iris-toolbox.com">www.iris-toolbox.com</a>
% _______________________________________________________________________________

%% function body --------------------------------------------------------------------------------------------

[rad,per] = xs2shift(F,varargin{:});

end

% end of primary function -----------------------------------------------------------------------------------