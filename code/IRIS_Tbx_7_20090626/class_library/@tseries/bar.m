function [handle,range,data] = bar(varargin)
% BAR  Bar plot function for time series.
%
% Syntax:
%   [h,rng] = bar(u,...)
%   [h,rng] = bar(rng,u,...)
%   [h,rng] = bar(ax,rng,u,...)
% Required input arguments:
%   h numeric; rng numeric; u tseries; ax numeric
% <a href="options.html">Optional input arguments:</a>
%   'dateformat' char (irisconfig.plotdateformat)
%   'datetick' numeric (Inf)
%   'function' function_handle (empty)
%   any Matlab BAR options

% The IRIS Toolbox 2009/03/03.
% Copyright 2007-2009 Jaromir Benes.

%********************************************************************
%! Function body.

[handle,range,data] = graph_(@bar,0.5,varargin{:});

end
% End of primary function.