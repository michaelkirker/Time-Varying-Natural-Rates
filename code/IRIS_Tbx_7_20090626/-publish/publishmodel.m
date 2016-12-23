function publishmodel(infile,outfile,varargin)
%
% PUBLISHMODEL  Publish model code as an HTML file.
%
% Syntax:
%   publishmodel(inputfile,outputfile,...)
% Required input arguments:
%   inputfile [ char ] Model code file name.
%   outputfile [ char ] Output document file name.
% <a href="options.html">Optional input arguments:</a>
%   'open' [ <a href="default.html">true</a> | false ] Open or not resulting HTML document in web browser.
%   'template' [ char | <a href="default.html">template.html</a> ] HTML template file.
%
% The IRIS Toolbox 2008/01/15. Copyright 2007-2008 Jaromir Benes. <a href="http://www.iris-toolbox.com">www.iris-toolbox.com</a>
% _______________________________________________________________________________

default = {...
  'open',false,...
  'template','htmlmodel.html',...
};
options = passopt(default,varargin{:});

%% function body --------------------------------------------------------------------------------------------

m = grabmodelcode(infile);
html = file2char(options.template);
[key,ctrl,math] = iriskeywords();
fcn = [ctrl,math];

% insert orginal code as comment at the beginning
html = strrep(html,'@originalcode',m);

% backmatter - after @stop
stoptag = '@stop';
position = strfind(m,stoptag);
if ~isempty(position)
  position = position(1);
  backmatter = m(position+length(stoptag):end);
  m = m(1:position+4);
else
  backmatter = '';
end

% frontmatter - before the first occurence of @
frontmatter = regexp(m,'^[^@]+\n','once','match');
m = regexprep(m,'^[^@]+\n','');

% brown labels
% must come first because span tags have double quotes in them
m = regexprep(m,'("[^"]*")','<span class="label">$1</span>');

% blue keywords
for i = 1 : length(key)
  m = strrep(m,key{i},sprintf('<span class="keyword">%s</span>',key{i}));
end

% red functions
for i = 1 : length(fcn)
  m = strrep(m,fcn{i},sprintf('<span class="function">%s</span>',fcn{i}));
end

% red time indices
m = regexprep(m,'(\{.*?\})','<span class="tindex">$1</span>');

% green line comments & remove all spans from comments
tokens = regexp(m,'(%.*?)(\r?\n)','tokens');
if ~isempty(tokens)
  m = regexprep(m,'(%.*?)(\r?\n)','\x{1}');
  tokens = [tokens{:}];
  tokens = regexprep(tokens,'</?span.*?>','');
  for i = 1 : 2 : length(tokens)
    m = regexprep(m,'\x{1}',sprintf('<span class="comment">%s</span>%s',tokens{i},tokens{i+1}),'once');
  end
end

% block comments
m = strrep(m,'/*',char(1));
m = strrep(m,'*/',char(2));
tokens = regexp(m,'(\x{1}[^\x{1}]*?\x{2})','tokens');
if ~isempty(tokens)
  tokens = [tokens{:}];
  tokens = regexprep(tokens,'</?span.*?>','');
  for i = 1 : length(tokens)
    m = regexprep(m,'\x{1}[^\x{1}]*?\x{2}',sprintf('<span class="comment">%s</span>',tokens{i}),'once');
  end
end
m = strrep(m,char(1),'/*');
m = strrep(m,char(2),'*/');

html = strrep(html,'@frontmatter',frontmatter);
html = strrep(html,'@code',m);
html = strrep(html,'@backmatter',backmatter);
if nargin == 1
  [fpath,ftitle,fext] = fileparts(infile);
  outfile = fullfile(fpath,sprintf('%s.html',ftitle));
end

char2file(html,outfile);

if options.open == true
  system(outfile);
end

end

%% end of primary function ----------------------------------------------------------------------------------