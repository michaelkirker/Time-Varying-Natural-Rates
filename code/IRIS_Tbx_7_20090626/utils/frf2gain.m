function F = frf2gain(F)
%
% FRF2GAIN  Gain of frequency response function.
%
% Syntax:
%   G = frf2gain(F)
% Output arguments:
%   G [ numeric ] Gain of frequency response function.
% Required input arguments:
%   F [ numeric ] Frequency response function.
%
% The IRIS Toolbox 2007/05/03. Copyright 2007 Jaromir Benes. <a href="www.iris-toolbox.com">www.iris-toolbox.com</a>

%! 

% ===========================================================================================================
%! function body

F = abs(F);

end
% end of primary function