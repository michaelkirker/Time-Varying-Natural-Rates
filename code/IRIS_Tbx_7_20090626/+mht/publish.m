function varargout = publish(inputFilename,varargin)
% Create HTML or MHT from an m-file or model code.

% The IRIS Toolbox 2009/01/26.
% Copyright (c) 2007-2008 Jaromir Benes.

%********************************************************************
%! Function body.

inputFilename = strtrim(inputFilename);
tmpExt = mht.extensionof(inputFilename);
if isempty(tmpExt) 
   tmpExt = '.m';
   inputFilename = [inputFilename,tmpExt];
end

if strcmpi(tmpExt,'.m')
   outputFilename = publishmfile_(inputFilename,varargin{:});
else
   outputFilename = publishmcode_(inputFilename,varargin{:});
end

varargout{1} = outputFilename;

end
% End of primary function.

%********************************************************************
%! Subfunction publishmfile().

function outputFilename = publishmfile_(mfile,varargin)

thisFileDir = fileparts(mfilename('fullpath'));
publishDir = fullfile(irisget('irisroot'),'-Publish');
newLine = char(10);

default = {...
   'alwaysmht',true,@islogical,...
};
[options,publishOptions] = extractopt(default(1:2:end),varargin{:});
options = passvalopt(default,options{:});
publishOptions = struct(publishOptions{:});

% Fixed options.
publishOptions.format = 'html';
publishOptions.stylesheet = fullfile(publishDir,'mxdom2irismht.xsl');
publishOptions.outputDir = tempname(cd());

% Merge CSS files and copy the resulting CSS code into HTML later.
list = {'mxdom2irismht.css','qtable.css'};
css = '';
for i = 1 : length(list)
   css = [css,newLine,newLine,file2char(fullfile(publishDir,list{i}))];
end
mkdir(publishOptions.outputDir);

% Publish HTML in temporary directory.
htmlFilename = publish(mfile,publishOptions);

% Insert CSS code into HTML.
html = file2char(htmlFilename);
html = strrep(html,'<style type="text/css"/>',['<style type="text/css">',css,'</style>']);
char2file(html,htmlFilename);

% If outputDIr contains only one HTML file, do not produce MHT.
list = mht.filesin(publishOptions.outputDir);
if ~options.alwaysmht && length(list) == 1 && strcmpi(mht.extensionof(list.name),'.html')
   outputExt = '.html';
else
   outputExt = '.mht';
end

% Determine output filename.
[tmpPath,tmpTitle] = fileparts(mfile);
outputFilename = fullfile(tmpPath,[tmpTitle,outputExt]);

if strcmp(outputExt,'.mht')
   % Convert HTML directory into MHT.
   mht.htmldir2mht(publishOptions.outputDir,outputFilename);
else
   % Copy HTML into output directory.
   copyfile(htmlFilename,outputFilename);
end

% Remove HTML directory.
rmdir(publishOptions.outputDir,'s');

end
% End of subfunction publishmfile_().

%********************************************************************
%! Subfunction publishmcode_()

function outputFilename = publishmcode_(mcodeFilename)

mcode = file2char(mcodeFilename);
thisFileDir = fileparts(mfilename('fullpath'));
publishDir = fullfile(irisget('irisroot'),'-Publish');
html = file2char(fullfile(publishDir,'mcode2html.html'));

% Insert model code source.
html = strrep(html,'<source/>',mcode);

% Block comments.
mcode = regexprep(mcode,'%\{','\x{0}');
mcode = regexprep(mcode,'%\}','\x{1}');
start = regexp(mcode,'\x{0}[^\x{0}]*\x{1}','start','once');
while ~isempty(start)
   mcode = regexprep(mcode,'\x{0}([^\x{0}]*)\x{1}','<span class="comment">%{$1%}</span>');
   start = regexp(mcode,'\x{0}[^\x{0}]*\x{1}','start','once');
end

% Code title: first lines starting with %%
codeTitle = '';
tmp = NaN;
while ~isempty(tmp);
   tmp = regexp(mcode,'(?m)%%\s*(.*?)\s*\r?\n','once','tokens');
   if ~isempty(tmp)
      codeTitle = [codeTitle,tmp{1},'<br/>'];
      mcode = regexprep(mcode,'(?m)%%\s*(.*?)\s*\r?\n','','once');
   end
end
% Remove last <br/>
if ~isempty(codeTitle)
   codeTitle(end-4:end) = '';
end

% Line comments.
mcode = regexprep(mcode,'(%.*?)\r?\n','<span class="comment">$1</span>\n');

% Keywords.
mcode = regexprep(mcode,'(![a-z][a-z0-9_:]*)','<span class="keyword">$1</span>');

% Labels.
mcode = regexprep(mcode,'(''[^'']*'')','<span class="label">$1</span>');

% Functions.
mcode = regexprep(mcode,'(\<[a-zA-Z]\w*\>)(?=\()','<span class="function">$1</span>');

% Lags and leads.
mcode = regexprep(mcode,'(?<!%)(\{[\+\-\d]\})','<span class="time">$1</span>');

% substitutions.
mcode = regexprep(mcode,'(\$.*?\$)','<span class="substitution">$1</span>');

% Include model code in HTML.
html = strrep(html,'<mcode/>',mcode);
html = strrep(html,'<codeTitle/>',codeTitle);

% Determine output filename.
[tmpPath,tmpTitle,tmpExt] = fileparts(mcodeFilename);
outputFilename = fullfile(tmpPath,[tmpTitle,'.html']);

char2file(html,outputFilename);

end
% End of subfunction publishmcode_().