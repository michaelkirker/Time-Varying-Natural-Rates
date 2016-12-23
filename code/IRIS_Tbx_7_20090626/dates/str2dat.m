function dat = str2dat(string,varargin)
% <a href="dates/str2dat">STR2DAT</a>  Convert cell array of string(s) to IRIS serial date number(s).
%
% Syntax:
%   dat = str2dat(s,...)
% Output arguments:
%   dat [ numeric ] IRIS serial date numbers.
% Required input arguments:
%   s [ cellstr ] Cell array of strings with dates.
% <a href="options.html">Options:</a>
%   'dateformat' [ char | <a href="default.html">'YYYYFPP'</a> ] Format of date strings.
%   'freq' [ numeric \ <a href="default.html">empty</a> ] Enforce frequency.
%   'freqletters' [ char | <a href="default.html">'YZQBM'</a> ] Letters to represent frequencies: annual, semi-annual, quarterly, bimonthly, monthly.

% The IRIS Toolbox 2009/01/30.
% Copyright (c) 2007-2009 Jaromir Benes.

freqletters = irisget('freqletters');

default = {
 'dateformat','YFP',...
 'freq',[],...
 'freqletters',freqletters,...
};
options = passopt(default,varargin{:});

%********************************************************************
%! Function body.

if ~isa(options.freqletters,'char') || length(options.freqletters) ~= 5
   options.freqletters = freqletters;
end

if ischar(string)
   string = {string};
end

if isempty(string)
   dat = nan(size(string));
   return
end

pattern = pattern_();
tokens = regexpi(string,pattern,'names','once');
[year,per,freq] = parsedates_(tokens,options);
dat = datcode(year,per,freq);

% Try indeterminate frequency.
index = vech(find(isnan(dat(:))));
for i = index
   aux = round(str2double(string{i}));
   if ~isempty(aux)
      dat(i) = aux;
   end
end

% end of function body

%********************************************************************
%! Nested function pattern_().

function x = pattern_()
   x = upper(options.dateformat);
   x = regexprep(x,'[\.\+\{\}\(\)]','\\$0');
   x = regexprep(x,'(?<!%)\*','.*');
   x = regexprep(x,'(?<!%)\?','.');
   x = regexprep(x,'(?<!%)YYYY','(?<longyear>\\d{4})');
   x = regexprep(x,'(?<!%)YY','(?<shortyear>\\d{2})');
   x = regexprep(x,'(?<!%)Y','(?<shortyear>\\d*)');
   x = regexprep(x,'(?<!%)PP','(?<longperiod>\\d{2})');
   x = regexprep(x,'(?<!%)P','(?<shortperiod>\\d*)');
   x = regexprep(x,'(?<!%)F',sprintf('(?<freqletter>[%s])',options.freqletters));
   x = regexprep(x,'(?<!%)MMMM','(?<wordmonth>january|february|march|april|may|june|july|august|september|october|november|december)');
   x = regexprep(x,'(?<!%)MMM','(?<wordmonth>jan|feb|mar|apr|may|jun|jul|aug|sep|oct|nov|dec)');
   x = regexprep(x,'(?<!%)MM','(?<numericmonth>\\d{1,2})');
   x = regexprep(x,'(?<!%)RM','(?<romanmonth>i|ii|iii|iv|v|vi|vii|viii|ix|x|xi|xii)');
   x = regexprep(x,'(?<!%)RP','(?<romanperiod>i|ii|iii|iv|v|vi|vii|viii|ix|x|xi|xii)');
   x = regexprep(x,'(?<!%)R','(?<romanperiod>i|ii|iii|iv|v|vi|vii|viii|ix|x|xi|xii)');
   x = regexprep(x,'(?<!%)I','(?<indeterminate>\\d+)');
   x = regexprep(x,'%([YPMRI])','$1');
end  
% End of nested function pattern_().

end
% End of primary function.

%********************************************************************
%! Subfunction parsedates_().

function [year,per,freq] = parsedates_(tokens,options)
  freqvec = [1,2,4,6,12];
  freq = nan(size(tokens));
  per = ones(size(tokens));
  year = nan(size(tokens));
  for i = 1 : length(tokens)
    if length(tokens{i}) ~= 1
      continue
    end
    if isfield(tokens{i},'indeterminate') && ~isempty(tokens{i}.indeterminate)
      freq(i) = 0;
      per(i) = str2num(tokens{i}.indeterminate);
      continue
    end
    if ~isempty(options.freq) && ( ...
          (isfield(tokens{i},'longmonth') && ~isempty(tokens{i}.longmonth)) ...
          || (isfield(tokens{i},'shortmonth') && ~isempty(tokens{i}.shortmonth)) ...
          || (isfield(tokens{i},'numericmonth') && ~isempty(tokens{i}.numericmonth)) )
      freq(i) = 12;
    end
    if isfield(tokens{i},'freqletter') && ~isempty(tokens{i}.freqletter)
      freqi = freqvec(upper(options.freqletters) == upper(tokens{i}.freqletter));
      if ~isempty(freqi)
        freq(i) = freqi;
      end
    end
    try
      yeari = str2double(tokens{i}.shortyear);
      if ~isempty(yeari)
        year(i) = yeari;
      end
    end
    try
      yeari = str2double(tokens{i}.longyear);
      if ~isempty(yeari)
        year(i) = yeari;
      end
    end
    try
      peri = str2double(tokens{i}.shortperiod);
      if isempty(peri)
        % if shortperiod is not found, set period to 1
        % to e.g. match YYYYFP with 2000Y
        per(i) = 1;
      else
        per(i) = peri;
      end
    end
    try
      peri = str2double(tokens{i}.longperiod);
      if ~isempty(peri)
        per(i) = peri;
      end
    end
    try
      peri = roman2num_(tokens{i}.romanperiod);
      if ~isempty(peri);
        per(i) = peri;
      end
    end
    mon = NaN;
    if isfield(tokens{i},'wordmonth')
      mon = month2num_(tokens{i}.wordmonth);
    elseif isfield(tokens{i},'numericmonth')
      mon = str2double(tokens{i}.numericmonth);
    elseif isfield(tokens{i},'romanmonth')
      mon = roman2num_(tokens{i}.romanmonth);
    end
    if ~isempty(options.freq)
      thisfreq = options.freq(min([i,end]));
      if any(thisfreq == freqvec)
         freq(i) = thisfreq;
      end
    end
    if ~isnan(mon)
       if ~isnan(freq(i)) && freq(i) ~= 12
          aux = 12 / freq(i);
          per(i) = 1 + floor(round(mon-1) / round(aux));
       else
          per(i) = mon;
          freq(i) = 12;
       end
    end
  end % of for
  % Try to guess freq by the highest period.
  if all(isnan(freq))
     maxper = max(per(~isnan(per)));
     if ~isempty(maxper)
        index = find(maxper <= freqvec,1,'first');
        if ~isempty(index)
           freq(:) = freqvec(index);
        end
     end
  end
end 
% End of subfunction parsedates_().

%********************************************************************
%! Subfunction month2num_().

function per = month2num_(month) 
   list = {'january','february','march','april','may','june','july','august','september','october','november','december'};
   per = find(strncmpi(month,list,length(month)));
   if isempty(per)
      per = NaN;
   end
end
% End of subfunction month2num_().

%********************************************************************
%! Subfunction roman2num_().

function per = roman2num_(romanper) 
   list = {'i','ii','iii','iv','v','vi','vii','viii','ix','x','xi','xii'};
   per = find(strcmpi(romanper,list));
   if isempty(per)
      per = NaN;
   end
end
% End of subfunction roman2num_().
