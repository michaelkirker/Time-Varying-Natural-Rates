function realsmall = getrealsmall(varargin)
%
% UTILS/GETREALSMALL  Context-specific tolerance.

% The IRIS Toolbox 2008/05/08.
% Copyright 2007-2008 Jaromir Benes.

% ===========================================================================================================
%! function body

if nargin > 0
   context = varargin{1};
else
   context = '';
end

switch lower(context)
case 'mse'
   realsmall = eps^(7/9);
otherwise
   realsmall = eps^(5/9);
end

end
% end of primary function