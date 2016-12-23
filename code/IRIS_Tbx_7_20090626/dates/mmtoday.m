function dat = mmtoday()
%
% <a href="dates/mmtoday">MMTODAY</a>  Serial date number for current month.
%
% Syntax:
%   dat = mmtoday()
% Output arguments:
%   dat [ numeric ]  Serial date number for current month.
%
% The IRIS Toolbox 2007/09/27. Copyright 2007 Jaromir Benes. <a href="http://www.iris-toolbox.com">www.iris-toolbox.com</a>
% _______________________________________________________________________________

%% function body --------------------------------------------------------------------------------------------

[year,month] = datevec(now());
dat = mm(year,month);

end

%% end of primary function ----------------------------------------------------------------------------------