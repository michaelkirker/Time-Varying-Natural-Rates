function [fg,ax,ln] = dbplot(d,list,range,varargin)
% DBPLOT  Plot a batch of series, or their transformations, from a
% database.
%
% Syntax:
%    [fg,ax,ln] = dbplot(d,list,range,...)
% Output arguments:
%    fg [ numeric ] Handles to figures created.
%    ax [ cell ] Handles to axes created.
%    ln [ cell ] Handles to lines created.
% Required input arguments:
%   d [ struct ] Input database.
%   list [ cellstr | char ] List of series or expressions to plot from the database.
%   range [ numeric ] Date range.
% Options:
%   'highlight' [ <a href="">empty</a> | numeric ] Date range to be higlighted.
%   'transform' [ <a href="">empty</a> | function_handle ] Function used to tranform each series.
%   'subplot' [ <a href="">'auto'</a> | numeric ] Subdivision of the figure.

% The IRIS Toolbox 2009/05/19.
% Copyright 2007-2009 Jaromir Benes.

default = {...
   'highlight',[],@isnumeric,...
   'transform',[],@(x) isempty(x) || isa(x,'function_handle'),...
   'subplot','auto',@(x) strcmpi(x,'auto') || (isnumeric(x) && length(x) == 2),...
};
[options,varargin] = extractopt(default(1:3:end),varargin{:});
options = passvalopt(default,options{:});

if ischar(list)
   list = charlist2cellstr(list);
end

%********************************************************************
%! Function body.

nlist = length(list);
nsub = ceil(sqrt(nlist));

if strcmpi(options.subplot,'auto')
   if nsub*(nsub-1) >= nlist
      nsub = [nsub,nsub-1];
   else
      nsub = [nsub,nsub];
   end
else
   nsub = options.subplot;
end

fg = [];
ax = {[]};
ln = {{}};

fg(end+1) = figure();
count = 0;
for i = 1 : nlist
   if ~isempty(regexp(list{i},'^\w+$','once'))
      x = d.(list{i});
   else
      x = dbeval(d,list{i});
   end
   tmptitle = list{i};
   if ~isempty(options.transform)
      x = options.transform(x);
   end
   count = count + 1;
   if count > prod(nsub)
      fg(end+1) = figure();
      ax{end+1} = [];
      ln{end+1} = {};
      count = 1;
   end
   ax{end}(end+1) = subplot(nsub(1),nsub(2),count);
   ln{end}{end+1} = plot(range,x,varargin{:});
   grid('on');
   title(tmptitle,'interpreter','none');
   if ~isempty(options.highlight)
      highlight(options.highlight);
   end
end

end
% End of primary function.