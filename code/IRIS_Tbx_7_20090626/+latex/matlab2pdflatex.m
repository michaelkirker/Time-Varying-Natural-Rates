function matlab2pdflatex(infile,outfile,varargin)

default = {...
  'closegraph',true,@islogical,...
  'deletetemp',true,@islogical,...
};
options = passvalopt(default,varargin{:});

% ===========================================================================================================
%! function body

config = irisconfig();
if isempty(config.texbinfolder)
  error('IRIS is not linked with LaTeX. Unable to use MATLAB2PDFLATEX.');
end
epstopdf = fullfile(config.texbinfolder,'epstopdf.exe');
pdflatex = fullfile(config.texbinfolder,'pdflatex.exe');

tempgraph = {};
tex = file2char(infile);
[inpath,intitle,inext] = fileparts(infile);
if ~isempty(inpath)
  error('Input file must be in current working directory.');
end

% remove line comments % ... and block comments /* ... */
tex = removecomments(tex,'%',{'/\*','\*/'});

% set default formats
writeformat = '%g';
tablerowformat = '$%.2f$';
dateformat = 'Y:P';

% set up pattern with all commands
list1 = {'Eval','Graph','Write','TableRow','Dates'};
list2 = {'WriteFormat','TableRowFormat','DateFormat'};
pattern = '';
for i = 1 : length(list1)
  pattern = [pattern,'|\\(',list1{i},')(\[.*?\])?\{\s*(.*?)\s*\}'];
end
for i = 1 : length(list2)
  pattern = [pattern,'|\\(',list2{i},')\{\s*(.*?)\s*\}'];
end
pattern = pattern(2:end);

[start,finish,tokens] = regexp(tex,pattern,'start','end','tokens','once');
while ~isempty(tokens) 
  replace = '';
  switch lower(tokens{1})
  case 'eval'
    try
      evalin('caller',tokens{3});
    end
  case 'graph'
    try
      evalin('caller',tokens{3});
    end
    replace = graph_(tokens{2});
  case 'write'
    try
      x = evalin('caller',tokens{3});
      tokens(end) = [];
      replace = write_(x,tokens{2});
    end
  case 'writeformat'
    writeformat = readformat_(tokens{2});
  case 'tablerow'
    try
      x = evalin('caller',tokens{3});
      replace = tablerow_(x,tokens{2});
    end
  case 'tablerowformat'
    tablerowformat = readformat_(tokens{2});
  case 'dates'
    format = tokens{2};
    if isempty(format)
      format = dateformat;
    else
      format = format(2:end-1);
    end
    try
      x = evalin('caller',sprintf('dat2str(%s,''%s'');',tokens{3},format));
      replace = dates_(x);
    end
  case 'dateformat'
    dateformat = tokens{2};
  end
  tex = [tex(1:start-1),replace,tex(finish+1:end)];
  [start,finish,tokens] = regexp(tex,pattern,'start','end','tokens','once');
end

% compile PDF
[ans,tmptex,ans] = fileparts(tempname());
char2file(tex,[tmptex,'.tex']);
system(sprintf('%s %s',pdflatex,[tmptex,'.tex']));
movefile([tmptex,'.pdf'],[intitle,'.pdf']);

if options.deletetemp
  % delete temp TeX file
  delete([tmptex,'.*']);
  % delete temporary graph PDFs
  for i = 1 : length(tempgraph)
    delete([tempgraph{i},'*']);
  end
end

%% end of function body -------------------------------------------------------------------------------------

%% nested function ------------------------------------------------------------------------------------------

  function replace = graph_(graphoptions)
  [ans,graphname,ans] = fileparts(tempname());
  print('-depsc',[graphname,'.eps']);
  system(sprintf('%s %s',epstopdf,[graphname,'.eps']));
  replace = sprintf('\\includegraphics%s{%s}',graphoptions,[graphname,'.pdf']);
  if options.closegraph
    close(gcf());
  end
  tempgraph{end+1} = graphname;
  end

%% end nested function matlabgraph_()  ----------------------------------------------------------------------

%% nested function ------------------------------------------------------------------------------------------

  function replace = write_(x,format)

  if isempty(format)
    format = writeformat;
  else
    format = readformat_(format);
  end
  if isnumeric(x)
    replace = sprintf(format,x);
  elseif ischar(x)
    replace = x;
  else
    replace = '';
  end
    
  end

%% end nested function write_()  -----------------------------------------------------------------------------

%% nested function ------------------------------------------------------------------------------------------

  function replace = tablerow_(x,format)

  if isempty(format)
    format = tablerowformat;
  else
    format = readformat_(format);
  end
  if isnumeric(x)
    replace = sprintf([format,' & '],x);
    if ~isempty(replace)
      replace = replace(1:end-3);
    end
  else
    replace = '';
  end
    
  end

%% end nested function write_()  -----------------------------------------------------------------------------

  function replace = dates_(x)

  replace = sprintf('%s & ',x{:});
  if ~isempty(replace)
    replace = replace(1:end-3);
  end

  end

%% end of nested function dates_()  --------------------------------------------------------------------------

%% nested function -------------------------------------------------------------------------------------------

  function format = readformat_(format)
  format = strrep(format(2:end-1),'#','%');
  end

%% end of nested function readformat_() ----------------------------------------------------------------------

end

%% end of primary function ----------------------------------------------------------------------------------
