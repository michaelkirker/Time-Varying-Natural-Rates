function x = compile(x,fname,varargin)
%
% COMPILE  Create PS or PDF file from report object.
%
% Syntax:
%   x = compile(x,fname,...)
% Required input arguments:
%   x report; fname char
% <a href="options.html">Optional input arguments:</a>
%   'deletetex' logical (true) Delete or not the LaTeX code used in the production of the PS or PDF file.
%   'display' logical (true) Display or not output messages from LaTeX, DVIPS and/or DVIPDFM.
%   'preamble' char ('preamble.tex') The preamble file name to replace the default file.
%
% The IRIS Toolbox 2007/05/03. Copyright 2007 Jaromir Benes. <a href="www.iris-toolbox.com">www.iris-toolbox.com</a>

% compile(x) without fname only saves report elements and quits

default = {...
  'deletetex',true,...
  'display',true,...
  'preamble','preamble.tex',...
};
options = passopt(default,varargin{:});

% ###########################################################################################################
% function body

chksyntax_(x.parenttype{end},'compile');

[code,reportoptions,epsfile] = code_(x);
if nargin == 1
  % save report elements only
  return
end 

config = irisconfig();
% Latex is linked
if isempty(config.latexpath)
  error_(6);
end

% Available font family passed in, TIMES otherwise
list = {'','times','palatino','newcent','bookman'};
if all(not(strcmp(reportoptions.fontname,list))), reportoptions.fontname = 'times'; end

% Available font size passed in, 11 otherwise
list = [10,11,12];
if ~isnumeric(reportoptions.fontsize) || all(reportoptions.fontsize ~= list), reportoptions.fontsize = 11; end

% Availabe paper size passed in, A4 otherwise
reportoptions.papersize = strrep(reportoptions.papersize,'paper','');
list = {'a4','letter','executive'};
if all(not(strcmp(reportoptions.papersize,list))), reportoptions.papersize = 'a4'; end

% Replace escape character # with \
code = strrep(code,'#','\');

% Add preamble.
texfile = reportcode_(options.preamble,reportoptions,code);

output = tempname;

[fpath,ftitle,fext] = fileparts(fname);
fext = lower(fext);
list = {'.ps','.pdf'};
exttype = strcmp(fext,list);
if all(exttype == false), error_(5); end

% Suppress output display if requested
if options.display, quiet = '';
  else, quiet = cellref({'-q*','-q'},find(exttype)); end

texfname = sprintf('%s.tex',ftitle);
char2file(texfile,texfname);

% compile dvi
texcommand = [config.latexpath,' ',texfname,iff(options.display,'',sprintf('>> %s',output))];
system(texcommand);
if ~options.display
  delete(output);
end

if find(exttype) == 2
  % PDF output
  if isempty(config.dvipdfmpath), error_(8); end
  systemstring = sprintf('%s -p %s %s %s %s.dvi',config.dvipdfmpath,reportoptions.papersize,iff(strcmp(reportoptions.orientation,'landscape'),'-l',''),quiet,ftitle);
else
  % PS output
  if isempty(config.dvipspath), error_(7); end
  systemstring = sprintf('%s -t %s %s %s %s.dvi -o %s.ps',config.dvipspath,reportoptions.papersize,iff(strcmp(reportoptions.orientation,'landscape'),'-t landscape',''),quiet,ftitle,ftitle);
end
system(systemstring);

% Delete auxiliary TeX files. Keep *.tex if desired
list = [iff(options.deletetex,{'tex'},{}),{'aux','log','dvi'}];
for i = 1 : length(list)
  delete(sprintf('%s.%s',ftitle,list{i}));
end

% Delete temporary EPS files
for i = 1 : length(epsfile)
  delete(epsfile{i});
end

% Move output file to desired folder
if ~isempty(fpath), flag = movefile(sprintf('%s%s',ftitle,fext),fpath); end

end
% end of primary function