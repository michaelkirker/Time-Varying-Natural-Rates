function dat = dec2dat(dec,freq)
%
% DEC2DAT  Decimal to internal representation conversion of dates.
%
% Syntax:
%   dat = dec2dat(dec,freq)
% Arguments:
%   dat numeric; dec numeric; freq numeric
%
% The IRIS Toolbox 2007/05/03. Copyright 2007 Jaromir Benes. <a href="www.iris-toolbox.com">www.iris-toolbox.com</a>

% function body ---------------------------------------------------------------------------------------------

if length(freq) == 1, freq = freq*ones(size(dec)); end

if freq == 0
  dat = dec;
else
  year = floor(dec);
  per = round((dec - year) .* freq) + 1;
  dat = datcode(year,per,freq);
end

end % of primary function -----------------------------------------------------------------------------------