function code = compile(this,fname,varargin)
% COMPILE  Compile HTML report.

% The IRIS Toolbox 2009/04/25.
% Copyright 2007-2009 Jaromir Benes.

default = {
   'alwaysmht',true,@islogical,...
};
options = passvalopt(default,varargin{:});

%********************************************************************
%! Function body.

[fpath,ftitle,fext] = fileparts(fname);

thefigure('clear');
code = report(this);
char2file(code,fullfile([fpath,ftitle,'.html']));
listOfFileNames = thefigure('get');
if options.alwaysmht
   listOfFileNames = [{fullfile([fpath,ftitle,'.html'])},listOfFileNames];
   mht.htmldir2mht(listOfFileNames,fullfile([fpath,ftitle,'.mht']));
end

end
% End of primary function.

%********************************************************************
% Subfunction report().

function code = report(this)

   precode = '<html>';
   postcode = '</html>';
   code = {};
   
   code{end+1} = head(this);
   code{end+1} = body(this);

   code = splicecode(precode,code{:},postcode);

end
% End of subfunction report().

%********************************************************************
% Subfunction head().

function code = head(this)

   precode = '<head><style type="text/css">';
   postcode = '</style></head>';
   code = {};
   
   code{end+1} = file2char(this.options.stylesheet);
   
   code = splicecode(precode,code{:},postcode);

end
% End of subfunction head().

%********************************************************************
% Subfunction body().

function code = body(this)

   precode = '<body>';
   postcode = '</body>';
   code = {};
   
   nchildren = length(this.children);
   for i = 1 : nchildren
      child = this.children{i};
      switch child.name
      case 'table'
         code{end+1} = table(child);
      case 'pagebreak'
         code{end+1} = pagebreak(child);
      case 'figure'
         code{end+1} = thefigure(child);
      end
   end
   
   code = splicecode(precode,code{:},postcode);

end
% End of subfunction body().

%********************************************************************
% Subfunction pagebreak().

function code = pagebreak(this)

   precode = '<div class="pagebreak"></div>';
   postcode = '';
   code = {};
   
   code = splicecode(precode,code{:},postcode);

end
% End of subfunction pagebreak().

%********************************************************************
% Subfunction table().

function code = table(this)

   precode = '<table>';
   postcode = '</table>';
   code = {};

   dates = this.options.range;
   caption = this.required{1};
   nchildren = length(this.children);
   code{end+1} = tablecols(this,dates);
   tabledata = {};
   tableformat = {};
   if ~isempty(caption)
      [tabledata{end+1},tableformat{end+1}] = tablecaption(this,caption);
   end
   [tabledata{end+1},tableformat{end+1}] = tabledates(this,dates);
   for i = 1 : nchildren
      child = this.children{i};
      switch child.name
      case 'row'
         [tabledata{end+1},tableformat{end+1}] = tablerow(child,dates);
      case 'subheading'
         [tabledata{end+1},tableformat{end+1}] = ...
            tablesubheading(child,dates);
      end
   end
   code{end+1} = cell2table(tabledata,tableformat);

   code = splicecode(precode,code{:},postcode);

end
% End of subfunction table().

%********************************************************************
% Subfunction tablecaption().

function [data,format] = tablecaption(this,caption)
   data = caption;
   format = 'table-caption';
end
% End of subfunction caption().

%********************************************************************
% Subfunction tablecols().

function code = tablecols(this,dates)

   precode = '';
   postcode = '';
   code = {};
   
   code(end+(1:3)) = {'<col class="table-leading-cols"/>'};
   nper = length(dates);
   for i = 1 : nper
      if any(round(dates(i)) == round(this.options.highlight))
         code{end+1} = '<col class="highlight" />';
      else
         code{end+1} = '<col />';
      end
   end
   code = {[code{:}]};

   code = splicecode(precode,code{:},postcode);
   
end
% End of subfunction tablecosl().

%********************************************************************
% Subfunction tabledates().

function [data,format] = tabledates(this,dates)
   nper = length(dates);
   ncol = nper + 3;
   data = cell([1,ncol]);
   format = cell([1,ncol]);
   data(1:3) = {''};
   data(4:end) = dat2str(dates,'dateFormat',this.options.dateformat);
   format(:) = {'table-dates'};
end
% End of subfunction tabledates().

%********************************************************************
% Subfunction tablerow().

function [data,format] = tablerow(this,dates)

   nper = length(dates);
   ncol = nper + 3;
   tmpdata = this.required{1}(dates);
   tmpdata = transpose(tmpdata(:,:));
   nalt = size(tmpdata,1);
   data = cell([nalt,ncol]);
   format = cell([nalt,ncol]);
   text = char(this.required{2});
   units = char(this.required{3});
   if ischar(this.options.mark)
      this.options.mark = {this.options.mark};
   end
   mark = cell([1,nalt]);
   mark(:) = {''};
   mark(1:length(this.options.mark)) = this.options.mark;
   data{1,1} = text;
   data{1,2} = units;
   for i = 1 : nalt
      data{i,3} = mark{i};
      data(i,4:end) = sprintfcell(this.options.format,tmpdata(i,:));
   end
   format(:,1) = {'table-row-text'};
   format(:,2) = {'table-row-units'};
   format(:,3) = {'table-row-mark'};
   format(:,4:end) = {'table-row-data'};
   
end
% End of subfunction tablerow().

%********************************************************************
% Subfunction tablerowi().

function x = sprintfcell(format,data)
   ndata = length(data);
   x = cell([1,ndata]);
   for i = 1 : ndata
      x{i} = sprintf(format,data(i));
   end
end
% End of subfunction tablerowi().

%********************************************************************
% Subfunction tablesubheading().

function [data,format] = tablesubheading(this,dates)
   data = this.required{1};
   format = 'subheading';
end

% End of subfunction tablesubheading().

%********************************************************************
% Subfunction thefigure().

function varargout = thefigure(varargin)

   persistent listOfFileNames;
   
   if ischar(varargin{1})
      action = varargin{1};
      switch action
      case 'clear'
         listOfFileNames = {};
      case 'get'
         varargout{1} = listOfFileNames;
      end
      return
   end
            
   this = varargin{1};
   precode = '<div class="figure">';
   postcode = '</div>';
   code = {};
   
   nchildren = length(this.children);
   sub = getsubplot(this.options.subplot,nchildren);
   fg = figure('visible','on','position',get(0,'screenSize'));
   for i = 1 : length(this.children)
      child = this.children{i};
      switch child.name
      case 'graph'
         ax = subplot(sub(1),sub(2),i);
         graph(child,fg,ax);
      end
   end
   fname = tempname(cd());
   [ans,fname] = fileparts(fname);
   fname = [fname,'.png'];
   print('-dpng',sprintf('-r%g',this.options.graphresolution),fname);
   %close(fg);
   code{end+1} = ['<img src="',fname,'"/>'];
   listOfFileNames{end+1} = fname;
   
   code = splicecode(precode,code{:},postcode);
   varargout{1} = code;
   
   function sub = getsubplot(option,n)
      if strcmpi(option,'auto')
         x = ceil(sqrt(n));
         if x*(x-1) >= n
            sub = [x,x-1];
         else
            sub = [x,x];
         end
      else
         sub = option(1:2);
      end
   end

end
% End of subfunction thefigure().

%********************************************************************
% Subfunction thefigure().

function graph(this,fg,ax)
   plot(qq(2000):qq(2004,4),tseries(qq(2000):qq(2004,4),@rand));
   set(ax,'fontSize',7,'fontName','Times','xgrid','on','ygrid','on');
   title('Title Title','fontName','Times','fontSize',7);
end
% End of subfunction graph().

%********************************************************************
% Subfunction splicecode().

function code = splicecode(varargin)

   nonempty = find(~cellfun(@isempty,varargin));
   
   code = '';
   for i = vech(nonempty)
      code = [code,varargin{i}];
      if i ~= nonempty(end)
         code = [code,char(10)];
      end
   end
   
end
% End of subfunction splicecode().

%********************************************************************
% Subfunction cell2table().

function code = cell2table(data,format)

   nrow = length(data);
   ncol = max(cellfun(@length,data));
   code = '';
   colspan = sprintf('%g',ncol);
   
   for i = 1 : nrow
      if ischar(data{i})
         % One cell spanning all columns.
         code = [code,'<tr>'];
         code = [code,...
            sprintf('<td colspan="%s" class="%s">',colspan,format{i}),...
            data{i},'</td>'];
         code = [code,'</tr>'];
      else
         % Individual cells.
         % Possibly with multiple alternatives.
         nalt = size(data{i},1);
         for j = 1 : nalt
            code = [code,'<tr>'];
            for k = 1 : ncol
               code = [code,...
                  sprintf('<td class="%s">',format{i}{j,k}),...
                  data{i}{j,k},'</td>'];
            end
            code = [code,'</tr>',char(10)];
         end
      end
      if i < nrow
         code = [code,char(10)];
      end
   end

end
% End of subfunction cell2table().