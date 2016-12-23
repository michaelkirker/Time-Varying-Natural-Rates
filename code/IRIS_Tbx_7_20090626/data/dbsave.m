function notsaved = dbsave(d,fname,range,varargin)
% DBSAVE  Save database as CSV file.
%
% Syntax:
%   list = dbsave(d,fname)
%   list = dbsave(d,fname,range,...)
% Output arguments:
%   list [ cellstr ] List of database entries that failed to be saved.
% Required input arguments:
%   d [ struct ] <a href="databases.html">Database</a> to be saved.
%   fname [ char ] CSV file name (including extension).
%   range [ numeric | <a href="default.html">Inf</a> ] Time range, i.e. <a href="dates.html">IRIS serial date numbers</a>.
% <a href="options.html">Optional input arguments:</a>
%  'arch' [ true | <a href="default.html">false</a> ] Add an extra 'ARCH' heading (for compatibility with TROLL CSV files).
%  'class' [ <a href="default.html">true</a> | false ] Include row with Matlab class specification.
%  'comment' [ <a href="default.html">true</a> | false ] Include comments (time series fields only).
%  'decimal' [ numeric | <a href="default.html">empty</a> ] Number of decimal places (overrides option 'format').
%  'format' [ char | <a href="default.html">'%.8e'</a> ] Numeric format.
%  'freqletters' [ char | 'YZQBM' ] Letters to represent date frequencies (annual, semi-annual, quarterly, bimonthly, monthly).
%  'nan' [ char | <a href="default.html">'NaN'</a> ] Representation of NaNs.

% The IRIS Toolbox 2009/05/06.
% Copyright 2007-2009 Jaromir Benes.

config = irisget();

default = {
  'arch',false,@islogical,...
  'class',true,@islogical,...
  'comment',true,@islogical,...
  'decimal',[],@(x) isempty(x) || (length(x) == 1 && isnumeric(x)),...
  'format','%.8e',@ischar,...
  'freqletters','YZQBM',@(x) ischar(x) && length(x) == 5,...
  'nan','NaN',@ischar,...
  'troll',false,@islogical,...
};
options = passvalopt(default,varargin{:});

if ~isempty(options.decimal)
  options.format = ['%.',sprintf('%g',options.decimal),'e'];
end

if ~isa(options.freqletters,'char') || length(options.freqletters) ~= length(config.freqletters)
  options.freqletters = config.freqletters;
end

options.freqletters(end+1) = '$';

%********************************************************************
%! Function body.

% allow both dbsave(d,fname) and dbsave(fname,d) 
if ischar(d) && isstruct(fname)
  [d,fname] = deal(fname,d);
end

if nargin < 3 || isinf1(range)
  range = 'max';
else
  range = vech(range);
end

tseriesname = {};
numericname = {};
notsaved = {};
list = fieldnames(d);
for i = 1 : length(list)
  if istseries(d.(list{i}))
    tseriesname(end+1) = list(i);
  elseif isnumeric(d.(list{i})) || islogical(d.(list{i})) || ischar(d.(list{i}))
    numericname(end+1) = list(i);
  else
    notsaved(end+1) = list(i);
  end
end

ntseries = length(tseriesname);
nnumeric = length(numericname);

name = {};
dim = {};
clss = {};
cmt = {};

% tseries entries
if ~isempty(tseriesname)
  array = [];
  for i = 1 : length(tseriesname)
    x = d.(tseriesname{i});
    si = size(x);
    ncol = prod(si(2:end));
    x = reshape(x,[si(1),ncol]);
    try
      array = [array,x];
    catch
      notsaved(end+1) = tseriesname(i);
      continue
    end
    dim(end+1) = {sprintf('[%g]',[Inf,si(2:end)])};
    dim(end+(1:ncol-1)) = {''};
    name(end+1) = tseriesname(i);
    name(end+(1:ncol-1)) = {''};
    clss(end+1) = {'tseries'};
    clss(end+(1:ncol-1)) = {''};
    cmt(end+(1:ncol)) = x.comment;
  end
  [data,range] = double(array,range);
else
  data = [];
  range = zeros([1,0]);
end
nper = length(range);

if ~isempty(notsaved)
  warning('Unable to save database entry: "%s".\n',notsaved{:});
end

% numeric entries
for i = 1 : length(numericname)
  x = d.(numericname{i});
  si = size(x);
  x = x(:,:);
  ncol = prod(si(2:end));
  if si(1) > nper
    n = si(1) - nper;
    range(end+(1:n)) = NaN;
    data(end+(1:n),:) = NaN;
  elseif si(1) < nper
    n = nper - si(1);
    x(end+(1:n),:) = NaN;
  end
  data = [data,x];
  dim(end+1) = {sprintf('[%g]',si)};
  dim(end+(1:ncol-1)) = {''};
  name(end+1) = numericname(i);
  name(end+(1:ncol-1)) = {''};
  clss(end+1) = {class(x)};
  clss(end+(1:ncol-1)) = {''};
  cmt(end+(1:ncol)) = {''};
end

fid = fopen(fname,'w+');
if fid == -1
  error(['Unable to open ''',upper(fname),''' for writing.']);
end

%try

% write leading ARCH row if troll format desired
if options.arch || options.troll
  aux = cell([1,length(name)-1]);
  aux(1:end) = {''};
  fwrite(fid,sprintf('ARCH%s\n',sprintf(',%s',aux{:})),'char');
end

% write names
fwrite(fid,sprintf('%s\n',sprintf(',%s',name{:})),'char');

% write comments
if options.comment
  cmt = regexprep(cmt,'(.*)','"$0"');
  fwrite(fid,sprintf('Comment%s\n',sprintf(',%s',cmt{:})),'char');
end

% write classes and sizes
if options.class && ~options.arch && ~options.troll
  aux = 'Class[Size]';
  for i = 1 : length(name)
    aux = [aux,','];
    if ~isempty(clss{i})
      aux = [aux,clss{i},dim{i}];
    end
  end
  aux = [aux,sprintf('\n')];
  fwrite(fid,aux,'char');
end

% date format string
[year,per,freq] = dat2ypf(range(:));
index = find(freq(1) == [1,2,4,6,12]);
if isempty(index)
  freqletter = '';
else
  freqletter = options.freqletters(index);
end
options.freqletter = strrep(options.freqletters,',',':');
options.freqletter = strrep(options.freqletters,';',':');
dateformat = ['%g',freqletter,'%g'];

% data format string
if size(data,2) > 0
  aux = cell([1,size(data,2)]);
  aux(1:end) = {options.format};
  dataformat = sprintf(',%s',aux{:});
end
formatline = [dateformat,dataformat,sprintf('\n')];
data = [year,per,data];
aux = sprintf(formatline,transpose(data));
if ~strcmp(lower(options.nan),'nan')
  aux = strrep(aux,'NaN',options.nan);
end

aux = strrep(aux,sprintf(dateformat,NaN,NaN),'NaN');
fwrite(fid,aux,'char');

%{
catch

fclose(fid);
error('Error when writing data to CSV file.');

end
%}

if fclose(fid) == -1
  warning(['Unable to close ''',upper(fname),''' after writing.']);
end

end
% End of primary function.