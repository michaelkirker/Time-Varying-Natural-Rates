function [handle,range,data] = plot(varargin)
% PLOT  Line plot function for time series.
%
% Syntax:
%   [h,rng] = plot(x,...)
%   [h,rng] = plot(rng,x,...)
%   [h,rng] = plot(ax,rng,x,...)
% Required input arguments:
%   h numeric; rng numeric; x tseries; ax numeric
% <a href="options.html">Optional input arguments:</a>
%   'dateformat' char (irisconfig.plotdateformat)
%   'datetick' numeric|Inf (Inf)
%   'function' function_handle (empty)
%   See also PLOT options.

% The IRIS Toolbox 2009/03/03.
% Copyright (c) 2007-2009 Jaromir Benes.

%********************************************************************
%! Function body.

[handle,range,data] = graph_(@plot,0,varargin{:});

end
% End of primary function.