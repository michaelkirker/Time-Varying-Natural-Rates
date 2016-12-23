function dat = zztoday()
%
% <a href="dates/zztoday">ZZTODAY</a>  Serial date number for current half-year.
%
% Syntax:
%   dat = zztoday()
% Output arguments:
%   dat [ numeric ]  Serial date number for current half-year.
%
% The IRIS Toolbox 2007/09/27. Copyright 2007 Jaromir Benes. <a href="http://www.iris-toolbox.com">www.iris-toolbox.com</a>
% _______________________________________________________________________________

%% function body --------------------------------------------------------------------------------------------

[year,month] = datevec(now());
dat = zz(year,1+floor((month-1)/6));

end

%% end of primary function ----------------------------------------------------------------------------------