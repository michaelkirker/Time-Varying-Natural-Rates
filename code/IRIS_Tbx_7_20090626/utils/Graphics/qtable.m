function qtable(cdfname,htmlfname,data,range,varargin)
% QTABLE  Quick HTML table.
%
% Syntax:
%    [hfig,hax,hline] = qplot(cdfname,htmlname,d,range)
% Output arguments:
%    hfig [ numeric ] Handles to figures created by QPLOT.
%    hax [ numeric ] Handles to axes created by QPLOT.
%    hline [ cell ] Handles to lines created by QPLOT.
% Required input arguments:
%    cdfname [ char ] Contents definition file name.
%    htmlname [ char | '' ] HTML output filename or screen output if no name provided.
%    d [ cell | struct ] Database or cell array of databases with input data.
%    range [ numeric ] Time range, i.e. <a href="dates.html">IRIS serial date numbers</a>.
% <a href="options.html">Optional input arguments:</a>
%    'caption' [ char | <a href="default.html">empty</a> ] Table caption.
%    'format' [ char | <a href="default.html">'%.2f'</a> ] Format for displaying numbers.
%    'nan' [ char | <a href="default.html">'...'</a> ] String to represent NaNs.
%    'open' [ <a href="default.html">true</a> | false ] Open table in Matlab web browser.

% The IRIS Toolbox 2009/04/24.
% Copyright 2007-2009 Jaromir Benes.

default = {...
   'caption','',@ischar,...
   'dateformat','YYYY:P',@ischar,...
   'format','%.2f',@ischar,...
   'highlight',[],@isnumeric,...
   'mark',{},@iscell,...
   'nan','...',@ischar,...
   'open',true,@islogical,...
};
options = passvalopt(default,varargin{:});

if ~ischar(cdfname) || (~ischar(htmlfname) && ~isempty(htmlfname)) || ~isstruct(data) || ~isnumeric(range)
   error('Incorrect type of input argument(s).');
end

%********************************************************************
%! Function body.

% read HTML template

% Read contents definition file.
[gd,sub] = readcdf(cdfname);
if isempty(gd) || isempty(fieldnames(gd))
   return
end

nper = length(range);

highlight = [];
if ~isempty(options.highlight)
   for i = 1 : nper
     if any(round(options.highlight - range(i)) == 0)
       highlight(end+1) = i;
     end
   end
   options.highlight = highlight;
end

code = '<table>';
options.caption = strtrim(options.caption);
if ~isempty(options.caption)
   code = [code,'<caption>',options.caption,'</caption>'];
end
code = [code,adddates_(range,options)];

newpanelseparator = true;
for i = 1 : length(gd)
   switch gd(i).tag
   case '!++'
      % Indicate a new page for the next panel.
      code = [code,addnewpage_(gd(i).title,nper)];
      if isempty(gd(i).title)
         newpanelseparator = false;
      end
   case '!--'
      [tmpformula,tmplegend] = charlist2cellstr(gd(i).body,'&\n');
      nformula = length(tmpformula);
      x = cell([1,nformula]);
      [x{:}] = dbeval(data,tmpformula{:});
      addcode = addpanel_(x,range,gd(i).title,tmplegend,newpanelseparator,options);
      code = [code,addcode];
      newpanelseparator = true;
   end
end
code = [code,'</table>'];

if isempty(htmlfname)
   disp('<html>');
   disp(code);
   disp('</html>');
else
   publishDir = fullfile(irisget('irisroot'),'-Publish');
   css = file2char(fullfile(publishDir,'qtable.css'));
   html = grabtext('==START OF HTML==','==END OF HTML==');
   html = strrep(html,char(13),'');
   html = strrep(html,'!css',css);
   html = strrep(html,'!contents',code);
   char2file(html,htmlfname);
   if options.open
      web(htmlfname);
   end
end

end
% end of primary function

%********************************************************************
%! Subfunction adddates_().

function code = adddates_(range,options);

x = dat2str(range,'dateformat',options.dateformat);
code = ['<tr>',repmat('<td class="date"></td>',[1,2])];
for i = 1 : length(x)
   if any(options.highlight == i)
      tmpclass = 'highlight';
   else
      tmpclass = '';
   end
   code = [code,sprintf(['<td class="date %s">%s</td>'],tmpclass,x{i})];
end
code = [code,'</tr>'];

end
% End of subfunctiono adddates_().

%********************************************************************
%! Subfunction addpanel_().

function code = addpanel_(x,range,title,legend,newpanelseparator,options)

nper = length(range);
nformula = length(x);
islegend = any(~cellfun(@isempty,legend));
code = '';
if newpanelseparator
   code = [code,addnewpanelseparator_(nper)];
end
for i = 1 : nformula
   data = x{i}(range,:);
   ndata = size(data,2);
   text = cell([1,ndata]);
   if ~islegend && i == 1
      text{1} = title;
      tmpclass = 'title';
   else
      text{1} = legend{i};
      tmpclass = 'legend';
   end
   text(2:end) = {''};
   mark = cell([1,ndata]);
   mark(:) = {''};
   n = min([length(options.mark),ndata]);
   mark(1:n) = options.mark(1:n);
   if islegend && i == 1
      code = [code,addtitle_(title,nper)];
   end
   for j = 1 : ndata
      code = [code,addrow_(data(:,j),text{j},mark{j},tmpclass,options)];
   end
end

end
% End of subfunctiono addpanel_().

%********************************************************************
%! Subfunction addnewpage_().

function code = addnewpage_(title,nper)
   code = sprintf('<tr><td colspan="%g" class="new-page-separator">&nbsp;</td></tr>',nper+2);
   if ~isempty(title)
      code = [code,sprintf('<tr><td colspan="%g" class="new-page">%s</td></tr>',nper+2,title)];
   end
end
% End of subfunction addnewpage_().

% ===========================================================================================================
%! subfunction addnewpanel_()

function code = addnewpanelseparator_(nper)
   code = sprintf('<tr><td colspan="%g" class="new-panel">&nbsp;</td></tr>',nper+2);
end
% end of subfunction addnewpanel_()

% ===========================================================================================================
%! subfunction addtitle_()

function code = addtitle_(text,nper)
   code = sprintf('<tr><td colspan="%g" class="title">%s</td></tr>',nper+2,text);
end
% end of subfunction addrow_()

% ===========================================================================================================
%! subfunction addrow_()

function code = addrow_(x,text,mark,class1,options)
data = '';
for i = 1 : length(x)
   if any(options.highlight == i)
      class2 = 'highlight';
   else
      class2 = '';
   end
   format = ['<td class="numeric ',class1,' ',class2,'">',options.format,'</td>'];
   data = [data,sprintf(format,x(i))];
end
data = strrep(data,'NaN',options.nan);
code = ['<tr>',...
   sprintf('<td class="text %s">%s</td>',class1,text),...
   sprintf('<td class="text %s">%s</td>',class1,mark),...
   data,'</tr>'];
end
% end of subfunction addrow_()

% =========================================================================================================== 
%! Contents Definition File (CDF) syntax

%{
   #2x2

   !-- Inflation
   'Headline' 400*dot_Pc
   'TR' 400*dot_Pt

   !-- Sacrifice ratio
   25*cumsum(log(C))

   !++

   !-- Inflation
   'Headline' 400*dot_Pc
   'NT' 400*dot_Pn
%}

%{
==START OF HTML==
<html>
<head>
<style type="text/css">
!css
</style>
</head>
<body>
!contents
</body>
</html>
==END OF HTML==
%}
