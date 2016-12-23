function [h,hu] = ploteig(x,varargin)
%
% PLOTEIG  Plot eigenvalues.
%
% Syntax:
%   h = ploteig(x,...)
% Output arguments:
%   h [ numeric ] Handle to plotted eigenvalues.
% Required input arguments:
%   x [ numeric | model | VAR ] Eigenvalues or object whose eigenvalues are to be plotted.
% Optional input arguments:
%   'ucircle' [ <a href="default.html">true</a> | false ] Draw unit circle.
% <a href="options.html">Optional input arguments:</a>
%   any Matlab plot options

% The IRIS Toolbox 2008/09/10.\
% Copyright (c) 2007-2008 Jaromir Benes.

[varargin,plotspec] = extractopt({'ucircle'},varargin{:});
default = {
   'ucircle',true,@islogical,...
};
options = passvalopt(default,varargin{:});

plotspec = [{'marker','x','markersize',8,'linestyle','none','linewidth',1.5},plotspec];

% ===========================================================================================================
%! function body 

if ~isnumeric(x)
   x = eig(x);
end

h = plot(real(x),imag(x),plotspec{:});

if options.ucircle
   nextplot = get(gca,'nextplot');
   set(gca,'nextplot','add');
   hu = ucircle();
   set(gca,'nextplot',nextplot);
end

end
% end of primary function