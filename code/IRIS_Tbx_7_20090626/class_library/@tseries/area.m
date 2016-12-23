function [handle,range] = area(varargin)
% Area  Area plot function for time series.
%
% Syntax:
%   [h,rng] = area(u,...)
%   [h,rng] = area(rng,u,...)
% Required input arguments:
%   h numeric; rng numeric; u tseries
% <a href="options.html">Optional input arguments:</a>
%   'dateformat' char (irisconfig.plotdateformat)
%   'datetick' numeric (Inf)
%   'function' function_handle (empty)
%   any Matlab PLOT options

% The IRIS Toolbox 2008/11/24.
% Copyright (c) 2007-2008 Jaromir Benes.

% =======================================================================================
%! Function body.

[handle,range] = graph_(@area,0,varargin{:});

end
% End of primary function.