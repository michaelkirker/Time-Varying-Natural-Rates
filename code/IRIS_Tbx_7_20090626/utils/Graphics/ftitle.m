function h = ftitle(varargin)
% Place titles in graphical window.
%
% Syntax:
%   h = ftitle(titles,...)
%   h = ftitle(h,titles,...)
% Output arguments:
%   h [ numeric ] Handles to annotation objects.
% Required input arguments:
%   h [ numeric ] Handle to graphical window.
%   titles [ cellstr | char ] Text string to be centred, or cell array of strings to be places LHS, centred, and RHS.

% The IRIS Toolbox 2008/09/05.
% Copyright (c) 2007-2008 Jaromir Benes.

if isnumeric(varargin{1})
  hfig = varargin{1};
  varargin(1) = [];
else
  hfig = gcf();
end

string = varargin{1};
varargin(1) = [];

if ischar(string)
   string = {string};
end

switch length(string)
case 0
   string = {'','',''};
case 1
   string = [{''},string,{''}];
case 2
   string = [string,{''}];
end

%********************************************************************
%! Function body.

options = [{'verticalAlignment','top','fontWeight','bold','lineStyle','none'},varargin];
h = [];
for i = vech(hfig)
  figure(i);
  if ~isempty(string{1})
     h(end+1) = annotation('textbox',[0,1,1,0],'string',string{1},'HorizontalAlignment','left',options{:},'FitBoxToText','on');
  end
  if ~isempty(string{2})
     h(end+1) = annotation('textbox',[0,1,1,0],'string',string{2},'HorizontalAlignment','center',options{:},'FitBoxToText','on');
  end
  if ~isempty(string{3})
     h(end+1) = annotation('textbox',[0,1,1,0],'string',string{3},'HorizontalAlignment','right',options{:},'FitBoxToText','on');
  end
end

end
% End of primary function.