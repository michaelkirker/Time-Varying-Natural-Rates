function dat = bbtoday()
%
% <a href="dates/bbtoday">BBTODAY</a>  Serial date number for current bimonth.
%
% Syntax:
%   dat = bbtoday()
% Output arguments:
%   dat [ numeric ]  Serial date number for current bimonth.
%
% The IRIS Toolbox 2007/09/27. Copyright 2007 Jaromir Benes. <a href="http://www.iris-toolbox.com">www.iris-toolbox.com</a>
% _______________________________________________________________________________

%% function body --------------------------------------------------------------------------------------------

[year,month] = datevec(now());
dat = bb(year,1+floor((month-1)/2));

end

%% end of primary function ----------------------------------------------------------------------------------