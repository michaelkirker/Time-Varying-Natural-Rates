function s = datstr(year,per,freq,dateformat,freqletters)
% DATSTR Character string representation of dates.

% The IRIS Toolbox 2009/06/09.
% Copyright (c) 2007-2008 Jaromir Benes.

%********************************************************************
%! Function body.

if freq == 0
   varyear = '';
   longyear = '';
   shortyear = '';
else
   varyear = sprintf('%g',year);
   longyear = sprintf('%04g',year);
   if length(longyear) > 2
      shortyear = longyear(end-1:end);
   else
      shortyear = longyear;
   end
end

% Convert escaped characters to coded values.
offset = 1000;
save = {'%Y','%y','%P','%p','%F','%f','%R','%r','%M','%m'};
for i = 1 : length(save)
   dateformat = strrep(dateformat,save{i},char(1000+i));
end

switch freq
case 0
   freqstring = '';
   shortarabper = sprintf('%g',per);
   longarabper = sprintf('%02g',per);
   numericmonth = NaN;
case 1
   freqstring = freqletters(1);
   shortarabper = '';
   longarabper = '';
   numericmonth = 12;
case 2
   freqstring = freqletters(2);
   shortarabper = sprintf('%g',per);
   longarabper = sprintf('%02g',per);
   numericmonth = per*6;
case 4
   freqstring = freqletters(3);
   shortarabper = sprintf('%g',per);
   longarabper = sprintf('%02g',per);
   numericmonth = per*3;
case 6
   freqstring = freqletters(4);
   shortarabper = sprintf('%g',per);
   longarabper = sprintf('%02g',per);
   numericmonth = per*2;
case 12
   freqstring = freqletters(5);
   shortarabper = sprintf('%02g',per);
   longarabper = sprintf('%02g',per);
   numericmonth = per;
otherwise
   freqstring = '?';
   shortarabper = sprintf('%g',per);
   longarabper = sprintf('%02g',per);
   numericmonth = NaN;
end
romanper = roman_(per);
lowerromanper = lower(romanper);
romanmonth = roman_(numericmonth);
lowerromanmonth = lower(romanmonth);
[longmonth,shortmonth] = wordmonth_(numericmonth);
numericmonth = sprintf('%02g',numericmonth);

s = dateformat;
s = regexprep(s,'YYYY',longyear,'ignorecase');
s = regexprep(s,'YY',shortyear,'ignorecase');
s = regexprep(s,'Y',varyear,'ignorecase');
s = regexprep(s,'PP',longarabper,'ignorecase');
s = regexprep(s,'P',shortarabper,'ignorecase');
s = strrep(s,'RP',romanper);
s = strrep(s,'RM',romanmonth);
s = strrep(s,'rp',lowerromanper);
s = strrep(s,'rm',lowerromanmonth);
s = strrep(s,'R',romanper);
s = strrep(s,'r',lowerromanper);
s = strrep(s,'F',upper(freqstring));
s = strrep(s,'f',lower(freqstring));

s = strrep(s,'Mmmm',longmonth);
s = strrep(s,'Mmm',shortmonth);
s = strrep(s,'mmmm',lower(longmonth));
s = strrep(s,'mmm',lower(shortmonth));
s = strrep(s,'MMMM',upper(longmonth));
s = strrep(s,'MMM',upper(shortmonth));
s = strrep(s,'MM',numericmonth);
s = strrep(s,'mm',numericmonth);

% Convert escaped characters back.
for i = 1 : length(save)
   s = strrep(s,char(offset+i),save{i}(2));
end

end
% End of primary function.

%********************************************************************
% Subfunction roman_().

function x = roman_(x)
   switch x
   case 1
      x = 'I';
   case 2
      x = 'II';
   case 3
      x = 'III';
   case 4
      x = 'IV';
   case 5
      x = 'V';
   case 6
      x = 'VI';
   case 7
      x = 'VII';
   case 8
      x = 'VIII';
   case 9
      x = 'IX';
   case 10 
      x = 'X';
   case 11
      x = 'XI';
   case 12
      x = 'XII';
   otherwise
      x = '';
   end
end
% End of subfunction roman_().

%********************************************************************
% Subfunction month_().

function [longmonth,shortmonth] = wordmonth_(m)
   switch m
   case 1
      longmonth = 'January';
   case 2
      longmonth = 'February';
   case 3
      longmonth = 'March';
   case 4
      longmonth = 'April';
   case 5
      longmonth = 'May';
   case 6
      longmonth = 'June';
   case 7
      longmonth = 'July';
   case 8
      longmonth = 'August';
   case 9
      longmonth = 'September';
   case 10
      longmonth = 'October';
   case 11
      longmonth = 'November';
   case 12
      longmonth = 'December';
   otherwise
      longmonth = '???';
   end
   shortmonth = longmonth(1:3);
end
% End of subfunction wordmonth_().