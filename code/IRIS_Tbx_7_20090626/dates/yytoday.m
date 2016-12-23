function dat = yytoday()
%
% <a href="dates/yytoday">YYTODAY</a>  Serial date number for current year.
%
% Syntax:
%   dat = yytoday()
% Output arguments:
%   dat [ numeric ]  Serial date number for current year.
%
% The IRIS Toolbox 2007/09/27. Copyright 2007 Jaromir Benes. <a href="http://www.iris-toolbox.com">www.iris-toolbox.com</a>
% _______________________________________________________________________________

%% function body --------------------------------------------------------------------------------------------

[year,month] = datevec(now());
dat = yy(year);

end

%% end of primary function ----------------------------------------------------------------------------------