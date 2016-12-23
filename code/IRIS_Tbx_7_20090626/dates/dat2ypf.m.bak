function [year,per,freq] = dat2ypf(dat)
%
% DAT2YPF  Decompose serial date number(s) into vectors(s) of year(s), period(s), and frequency(ies).
%
% Syntax:
%   [y,p,f] = dat2ypf(dat)
% Output arguments:
%   y [ numeric ] Year(s).
%   p [ numeric ] Perios(s), i.e. half-year(s), quarter(s), bimonth(s), or month(s).
% Required input arguments:
%   dat [ numeric ] <a href="dates.html">IRIS serial date number(s)</a>.
%
% The IRIS Toolbox 2007/09/27. Copyright 2007 Jaromir Benes. <a href="http://www.iris-toolbox.com">www.iris-toolbox.com</a>

% ###########################################################################################################
%% function body

yp = floor(dat);
freq = datfreq(dat);
index = freq == 0;

[year,per] = deal(nan(size(dat)));

% normal frequencies
year(~index)  = floor(yp(~index) ./ freq(~index));
per(~index) = round(yp(~index) - year(~index).*freq(~index) + 1);

% indeterminate frequency
year(index) = 0;
per(index) = dat(index); 

end
% end of primary function