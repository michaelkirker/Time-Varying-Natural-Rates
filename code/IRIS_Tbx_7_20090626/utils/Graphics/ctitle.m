function h = ctitle(varargin)
%
% <a href="matlab: edit utils/graphics/ctitle">CTITLE</a>  Centered title in graphical window.
%
% Syntax:
%   h = ctitle(title,...)      (1)
%   h = ctitle(f,title,...)    (2)
% Output arguments:
%   h [ numeric ] Handles to titles.
% Required input arguments:
%   title [ char ] Centered text on top of window.
% Required input arguments for syntax (2):
%   f [ numeric ] Handle to figure.
%
% The IRIS Toolbox 2007/05/03. Copyright 2007 Jaromir Benes. <a href="www.iris-toolbox.com">www.iris-toolbox.com</a>
% _______________________________________________________________________________

if isnumeric(varargin{1})
  h = varargin{1};
  string = varargin{2};
  varargin(1:2) = [];
else
  h = gcf();
  string = varargin{1};
  varargin(1) = [];
end

%% function body --------------------------------------------------------------------------------------------

figure(h);
axes('Position',[0,0,1,1],'Visible','off');
h = text(0.5,0.98,string,'HorizontalAlignment','Center',varargin{:}); %,'fontsize',11,'fontweight','bold');

end

%% end of primary function ----------------------------------------------------------------------------------