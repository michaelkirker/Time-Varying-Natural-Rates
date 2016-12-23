function freq = datfreq(dat)
%
% <a href="dates/datfreq">DATFREQ</a>  Frequency(ies) of date(s).
%
% Syntax:
%   freq = datfreq(dat)
% Output arguments:
%   freq [ numeric ] Frequency(ies):  0=indefinite, 1=annual, 2=semiannual, 4=quarterly, 6=bimonthly, 12=monthly.
% Required input arguments:
%   dat [ numeric ] <a href="dates.html">IRIS serial date number(s)</a>.
%
% The IRIS Toolbox 2007/05/09. Copyright 2007 <a href="mailto:jaromir.benes@gmail.com?subject=The%20IRIS%20Toolbox%3A%20%5Byour%20subject%5D">Jaromir Benes</a>. <a href="www.iris-toolbox.com">www.iris-toolbox.com</a>

% ###########################################################################################################
%% function body

freq = round(100*(dat - floor(dat)));

end
% end of primary function