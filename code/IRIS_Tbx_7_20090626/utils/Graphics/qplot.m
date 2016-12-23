function [hfig,hax,hline,htit,plotdb,latexcode] = qplot(cdfname,data,range,varargin)
%
% QPLOT  Quick plot function based on Graph Definition File.
%
% Syntax:
%    [hfig,hax,hline,htit,plotdb] = qplot(cdfname,d,range,...)
% Output arguments:
%    hfig [ numeric ] Handles to figures created by QPLOT.
%    hax [ cell ] Handles to axes created by QPLOT.
%    hline [ cell ] Handles to lines created by QPLOT.
%    htit [ numeric ] Handles to titles created by QPLOT.
%    plotdb [ struct ] Database with actually plotted series.
% Required input arguments:
%    cdfname [ char ] Contents definition file name.
%    d [ struct ] Database with input data.
%    range [ numeric ] Time range, i.e. <a href="dates.html">IRIS serial date numbers</a>.
% <a href="options.html">Optional input arguments:</a>
%    'caption' [ char | <a href="default.html">empty</a> ] Figure caption.
%    'plot' [ function_handle | <a href="default.html">@qpdefault</a> ] Plot function handle.
%    'saveas' [ char | <a href="default.html">empty</a> ] Save figures to file.

% The IRIS Toolbox 2008/10/20.
% Copyright (c) 2007-2008 Jaromir Benes.

% Validate required input arguments.
p = inputParser();
p.addRequired('filename',@(x) ischar(x) || isa(x,'function_handle'));
p.addRequired('dbase',@(x) isstruct(x));
p.addRequired('range',@isnumeric);
p.parse(cdfname,data,range);

% Extract qplot options. The others are passed to the plotting function. 
[options,varargin] = extractopt(...
   {'mark','plot','copyfigure','figure','axes','line','zeroline','title','prefix'},...
   varargin{:});
default = {...
   'axes',{},@(x) isempty(x) || (iscell(x) && iscellstr(x(1:2:end))),...
   'drawnow',false,@islogical,...
   'title',{},@(x) isempty(x) || (iscell(x) && iscellstr(x(1:2:end))),...
   'figure',{},@(x) isempty(x) || (iscell(x) && iscellstr(x(1:2:end))),...
   'line',{},@(x) isempty(x) || (iscell(x) && iscellstr(x(1:2:end))),...
   'mark',{},@(x) iscell(x) || ischar(x),...
   'plot',@qpdefault,@(x) isa(x,'function_handle'),...
   'prefix','P%g_',@ischar,...
   'copyfigure',false,@islogical,...
   'zeroline',false,@islogical,...
};
options = passvalopt(default,options{:});

if nargin < 3
   range = Inf;
end

if ischar(options.mark)
   options.mark = {options.mark};
end

options.mark = strtrim(options.mark);

%********************************************************************
%! Function body.

% Read contents definition file.
gd = readcdf(cdfname);

hfig = [];
hax = {};
hline = {};
htit = [];
if isempty(gd)
   return
end

% Count number of panels on each page.
page = 0;
count = 1;
npanel = [];
while count <= length(gd)
   switch gd(count).tag
   case '!++'
      page = page + 1;
      npanel(page) = 0;
   case {'!--','!::','!**'}
      npanel(page) = npanel(page) + 1;
   end
   count = count + 1;
end

%latex_('clear');
%latex_('start',range);
%latex_('dates',range);
sub = 'auto';
pos = 1;
count = 1;
page = 0;
plotdb = struct();
for i = 1 : length(gd)
   switch gd(i).tag
   case '#'
      % Change subplot division.
      sub = strtrim(gd(i).title);
   case '!++'
      % New figure.
      hfig(end+1) = figure();
      hax{end+1} = [];
      hline{end+1} = {};
      if ~isempty(gd(i).title)
         ftitle(hfig(end),gd(i).title);
      end
      pos = 1;
      page = page + 1;
      [nrow,ncol] = getsubplot_(sub,npanel(page));    
   case {'!**'}
      % Skip current subplot position.
      pos = pos + 1;
   case {'!--','!::'}
      % New panel.
      % Draw a line (!--) or bar (!::) plot.
      hax{end}(end+1) = subplot(nrow,ncol,pos);
      [tmpformula,tmplegend] = charlist2cellstr(gd(i).body,'&\n');
      nformula = length(tmpformula);
      x = cell([1,nformula]);
      [x{:}] = dbeval(data,tmpformula{:});
      switch gd(i).tag
      case '!--'
         type = 'line';
      case '!::'
         type = 'bar';
      end
      try
      [hline{end}{end+1},tmprange,tmpdata] = ...
        feval(options.plot,range,x,type,@legend_,varargin{:});
      catch me
         warning('iris:qplot',...
            'Error when plotting %s.\nMatlab says: %s',...
            gd(i).body,me.message);
      end
      tmptitle = '';
      if ~isempty(gd(i).title)
         % Add title to current subplot.
         tokens = regexp(gd(i).title,'^(.*?)(\\\\.*)?$','tokens','once');
         tmptitle = strtrim(tokens{1});
         tokens{2} = strtrim(tokens{2}(3:end));         
         if ~isempty(tokens{2})
            tmptitle = [tmptitle,char(10),tokens{2}];
         end
         htit(end+1) = title(hax{end}(end),tmptitle);
      end
      % latex_('panel',range,x,tmptitle);
      % Create a name for the entry in the output database based on the
      % (user-supplied) prefix and the current panel's name. Substitute '_'
      % for any [^\w]. If not a valid Matlab name, replace with "Panel#".
      prefix = sprintf(options.prefix,count);
      if nargout > 4
         tmpname = [prefix,regexprep(tmptitle,'[^\w]+','_')];      
         if ~isvarname(tmpname)
            tmpname = sprintf('Panel%g',count);
         end
         plotdb.(tmpname) = tseries(tmprange,tmpdata,options.mark);
      end
      pos = pos + 1;
      count = count + 1;
   end
end

% latex_('end');
% latexcode = latex_('getcode');
latexcode = '';

setproperties_(hfig,hax,htit,hline,options);
if options.drawnow
   drawnow();
end

% End of function body.

%********************************************************************
%! Nested function legend_().

function outputlegend = legend_()
   % Splice legend and marks.
   outputlegend = {};
   for j = 1 : length(x)
      for k = 1 : size(x{j},2)
         outputlegend{end+1} = '';
         if length(tmplegend) >= j
            outputlegend{end} = [outputlegend{end},tmplegend{j}];
         end
         if length(options.mark) >= k
            outputlegend{end} = [outputlegend{end},options.mark{k}];
         end
      end
   end
end
% End of nested function legend_().

end
% End of primary function.

%********************************************************************
%! Subfunction getsubplot_().

function [nrow,ncol] = getsubplot_(sub,npanel)

if ~strcmpi(sub,'auto')
   tmp = sscanf(sub,'%gx%g');
   if isnumeric(tmp) && length(tmp) == 2 && ~any(isnan(tmp))
      nrow = tmp(1);
      ncol = tmp(2);
   else
      sub = 'auto';
   end
end

if strcmpi(sub,'auto')
   x = ceil(sqrt(npanel));
   if x*(x-1) >= npanel
      nrow = x;
      ncol = x-1;
   else
      nrow = x;
      ncol = x;
   end
else

end
   
end
% End of subfunction getsubplot_().

%********************************************************************
%! Subfunction setproperties_().

function [nrow,ncol] = setproperties_(fg,ax,ti,ln,options)

% Figure properties.
if ~isempty(options.figure)
   set(fg,options.figure{:});
end

% Axes properties.
if ~isempty(options.axes)
   for i = 1 : length(ax)
      set(ax{i},options.axes{:});
   end
end

% Title properties.
if ~isempty(options.title)
   %for i = 1 : length(ti)
      set(ti,options.title{:});
   %end
end

% Line properties.
if ~isempty(options.line)
   for k = 1 : length(ln)
      for m = 1 : length(ln{k})
         % ln{k}{m} is vector of handles to all lines in figure k axes m.
         for i = 1 : 2 : length(options.line)
            if iscell(options.line{i+1})
               for j = 1 : min([length(ln{k}{m}),length(options.line{i+1})])
                  set(ln{k}{m}(j),options.line{i},options.line{i+1}{j});
               end
            else 
               set(ln{k}{m},options.line{i:i+1});
            end
         end
      end   
   end
end

end
% End of subfunction setproperties_().

%********************************************************************
%! Subfunction latex_().

function varargout = latex_(action,varargin)

persistent code repository dates;

switch action
case 'clear'
   code = '';
   repository = {};
   dates = {};
   add = '';
case 'start'
   dates = varargin{1};
   nper = length(dates);
   colspec = 'r';
   colspec = colspec(ones([1,nper]));
   add = ['\settowidth{\tablecolwidth}{!1} \begin{tabular}{ll',colspec,'} \hline '];
case 'dates'
   dates = varargin{1};
   dates = dat2str(dates);
   dates = sprintf(' & \\makebox[\\tablecolwidth][r]{%s}',dates{:});
   add = [' &',dates,'\\ \hline'];
case 'panel'
   dates = varargin{1};
   x = [varargin{2}{:}];
   data = sprintf(' & $%.2f$',x(dates));
   repository = [repository,regexp(data,'\$[\-\d\.]+\$','match')];
   tmptitle = varargin{3};
   add = [tmptitle,' &',data,'\\'];
case 'end'
   add = '\hline \end{tabular}';
   repository = [dates,repository];
   n = cellfun(@length,repository);
   n(length(dates)+1:end) = n(length(dates)+1:end) - 2;
   [ans,index] = max(n);
   code = strrep(code,'!1',repository{index});
case 'getcode'
   varargout{1} = code;
   add = '';
end

if ~isempty(add)
   code = [code,char(10),add];
end

end
% End of subfunction latex_().