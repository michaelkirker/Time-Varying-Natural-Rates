function x = horzcat(varargin)
% HORZCAT  Horizontal concatenation of time series.
%
% Syntax:
%   x = horzcat(x,<y>)
%   x = [x,<y>]
% Arguments
%   x tseries; y tseries

% The IRIS Toolbox 2009/06/09.
% Copyright 2007-2009 Jaromir Benes.

%********************************************************************
%! Function body.

x = cat(2,varargin{:});

end
% End of primary function.