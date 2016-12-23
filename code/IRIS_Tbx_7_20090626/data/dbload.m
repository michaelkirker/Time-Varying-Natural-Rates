function d = dbload(fname,varargin)
% <a href="matlab: edit data/dbload">DBLOAD</a>  Load database from CSV file.
%
% Syntax:
%   d = dbload(fname,...)
% Output arguments:
%   d [ struct ]  <a href="databases.html">Database</a> created from CSV file.
% Required input arguments:
%   fname [ char ] CSV file name.
% <a href="options.html">Optional input arguments:</a>
%   'case' [ 'lower' | 'upper' | <a href="default.html">empty</a> ] Change case of variables names.
%   'dateformat' [ char | <a href="default.html">'YYYYFP'</a> ] Format of dates.
%   'freq' [ 0 | 1 | 2 | 4 | 6 | 12 | <a href="default.html">empty</a> ] Enforced frequency of dates (automatically recognised otherwise).
%   'freqletters' [ char | <a href="default.html">'YZQBM'</a> ] Letters representing date frequencies (annual, semi-annual, quarterly, bimonthly, monthly).
%   'skiprows' [ char | cellstr | <a href="default.html">'[a-zA-Z].*'</a> ] Labels at starts of rows that are to be ignored.
%   'commentrow' [ char | cellstr ] Label at start of row that is to be treated as a comment row.
%   'nan' [ cellstr | char | <a href="default.html">{'na','#n/a'}</a> ] Representation of missing observations (in addition to 'NaN' and 'nan').

% The IRIS Toolbox 2009/02/23.
% Copyright 2007-2009 Jaromir Benes.

default = {...
   'case','',@(x) isempty(x) || any(strcmpi(x,{'lower','upper'})),...
   'changecase','',@(x) isempty(x) || any(strcmpi(x,{'lower','upper'})),...
   'commentrow',{'comment','comments'},@(x) ischar(x) || iscellstr(x),...
   'dateformat','',@ischar,...
   'freq',[],@(x) isempty(x) || (ischar(x) && strcmpi(x,'daily')) || (length(x) == 1 && isnan(x)) || (isnumeric(x) && length(x) == 1 && any(x == [0,1,2,4,6,12])),...
   'freqletters','YZQBM',@(x) ischar(x) && length(x) == 5,...
   'nan',{'na','#n/a','n.a.'},@(x) ischar(x) || iscellstr(x),...
   'skiprows','[a-zA-Z].*',@(x) isempty(x) || ischar(x) || iscellstr(x),...
};
options = passvalopt(default,varargin{1:end});

if isempty(options.dateformat)
   if strcmpi(options.freq,'daily')
      options.dateformat = 'dd/mm/yyyy';
   else
      options.dateformat = 'YFP';
   end
end

if ~isempty(options.changecase) && isempty(options.case)
   options.case = options.changecase;
end

if ischar(options.nan)
   options.nan = {options.nan};
end

if ischar(options.skiprows)
   options.skiprows = {options.skiprows};
end

if ~isempty(options.skiprows)
   for i = 1 : length(options.skiprows)
      if isempty(options.skiprows{i})
         continue
      end
      if options.skiprows{i}(1) ~= '^'
         options.skiprows{i} = ['^',options.skiprows{i}];
      end
      if options.skiprows{i}(end) ~= '$'
         options.skiprows{i} = [options.skiprows{i},'$'];
      end         
   end
end

if ischar(options.commentrow)
   options.commentrow = {options.commentrow};
end

%********************************************************************
%! Function body.

d = struct();

% Read file.
text = file2char(fname);
text = strrep(text,char(13),'');

% Read headings.
name = {};
class = {};
comment = {};
isdate = false;
eol = (text == char(10));
oldclasssyntax = false;
while ~isempty(text) && ~isdate
   pos = find(eol,1);
   if isempty(pos)
      line = text;
   else
      line = text(1:pos-1);
   end
   tokens = regexp(line,'([^",]*),|([^",]*)$|"(.*?)",|"(.*?)"$','tokens');
   tokens = [tokens{:}];
   if isempty(tokens) || all(cellfun(@isempty,tokens))
      ident = '%';
   else
      ident = lower(strtrim(tokens{1}));
   end   
   if strncmp(ident,'%',1)
      action = 'do_nothing';
   elseif ~isempty(strfind(ident,'class[size]'))
      class = tokens(2:end);
      action = 'class';
   elseif ~isempty(strfind(ident,'class'))
      class = tokens(2:end);
      oldclasssyntax = true;
      action = 'class';
   elseif any(strcmpi(ident,options.commentrow))
      comment = tokens(2:end);
      action = 'comment';
   elseif isempty(ident)
      name = tokens(2:end);
      action = 'name';
   elseif any(~cellfun(@isempty,regexp(ident,options.skiprows,'start')))
      action = 'do_nothing';
   elseif ~isempty(ident)
      isdate = true;
      action = 'date';
   end
   if ~strcmp(action,'date')
      if ~isempty(pos)
         text = text(pos+1:end);
         eol = eol(pos+1:end);
      else
         text = '';
         eol = [];
      end
   end
end

class = strtrim(class);
comment = strtrim(comment);
if length(class) < length(name)
   class(length(class)+1:length(name)) = {''};
end
if length(comment) < length(name)
   comment(length(comment)+1:length(name)) = {''};
end

if ~isempty(text)
   % Read date column (first column).
   datecol = regexp(text,'(?:^|\n)([^,\n]*)','tokens');
   datecol = [datecol{:}];
   datecol = strtrim(datecol);
   % Delete contents of date column.
   text = regexprep(text,'(^|\n)[^,\n]*','$1');
   % Replace NaNs.
   for i = 1 : length(options.nan)
      text = regexprep(text,['\<',options.nan{i},'\>'],'nan','ignorecase');
   end
   % Read numeric data.
   data = dlmread_(text,',');
   % Remove first column that used to be dates but is NaNs now.
   data(:,1) = [];
   tmpnper = size(data,1);
   if length(datecol) > tmpnper
      datecol = datecol(1:tmpnper);
   end
   if ~isempty(datecol)
      % Remove rows with empty dates.
      emptydate = cellfun(@isempty,datecol);
      datecol(emptydate) = [];
      data(emptydate,:) = [];   
   end
   % Convert date strings.
   if ~isempty(datecol)   
      if strcmpi(options.freq,'daily')
         dates = datenum(datecol,options.dateformat);
      else
         dates = str2dat(datecol,'dateformat',options.dateformat,'freq',options.freq,'freqletters',options.freqletters);
      end
      % Exclude rows that produce NaN dates.
      nandate = isnan(dates);
      dates(nandate) = [];
      data(nandate,:) = [];
   end
   % Check that all dates have the same frequency.
   if ~isempty(dates)
      tmpfreq = datfreq(dates);
      if any(tmpfreq(1) ~= tmpfreq)
         error('Dates in CSV database "%s" have mixed frequencies.',fname);
      end
   end
else
   dates = [];
   data = [];
end

switch lower(options.case)
case 'lower'
   name = lower(name);
case 'upper'
   name = upper(name);
end

nper = size(data,1);
while ~isempty(name)
  thisname = name{1};
  if isempty(thisname)
    ncol = 1;
  else
    tokens = regexp(class{1},'^(\w+)(\[.*\])?','tokens','once');
    if isempty(tokens)
      class_ = '';
      dim = [];
    else
      class_ = lower(tokens{1});
      dim = sscanf(tokens{2},'[%g]');
      if isempty(dim)
        dim = [];
      else
        dim = vech(dim);
      end
    end
    if isempty(class_)
      class_ = 'tseries';
    end
    % Replace all non-\w characters with underscores.
    thisname = regexprep(thisname,'[^\w]','_');
    if strcmp(class_,'tseries')
      if isempty(dim)
        dim = [Inf,1];
      elseif oldclasssyntax
        dim = [Inf,dim];
      end
      ncol = prod(dim(2:end));
      if ~isempty(data)
         data_ = reshape(data(:,1:ncol),[nper,dim(2:end)]);
         d.(thisname) = tseries(dates,data_,comment(1:ncol));
       else
         d.(thisname) = tseries([],zeros([0,dim(2:end)]));
       end
    else
      if oldclasssyntax
        ncol = 1;
        data_ = reshape(data(1:prod(dim),1),dim);
        d.(thisname) = eval(sprintf('%s(data_)',class_));
      else
        ncol = prod(dim(2:end));
        data_ = reshape(data(1:dim(1),1:ncol),dim);
        d.(thisname) = eval(sprintf('%s(data_)',class_));
      end
    end
  end
  data = data(:,ncol+1:end);
  name = name(ncol+1:end);
  comment = comment(ncol+1:end);
  class = class(ncol+1:end);
end

end
% End of primary function.