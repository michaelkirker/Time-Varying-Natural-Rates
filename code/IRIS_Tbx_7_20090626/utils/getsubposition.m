function x = getsubposition(varargin)
% GETSUBPOSITION  Determine position of the specified subplot panel.

% The IRIS Toolbox 2009/02/20.
% Copyright 2007-2009 Jaromir Benes.

%********************************************************************
%! Function body.

f = figure('visible','off');
if nargin == 1
   ax = subplot(varargin{1}(1),varargin{1}(2),varargin{1}(3));
else
   ax = subplot(varargin{:});
end
x = get(ax,'position');
close(f);

end
% End of primary function.