function [handle,range] = stem(varargin)
%
% STEM Stem plot function for times series.
%
% Syntax:
%   [h,rng] = stem(x,...)
%   [h,rng] = stem(rng,x,...)
%   [h,rng] = stem(ax,rng,x,...)
% Required input arguments:
%   h numeric; rng numeric; x tseries; ax numeric
% <a href="options.html">Optional input arguments:</a>
%   'dateformat' char (irisconfig.plotdateformat)
%   'datetick' numeric|Inf (Inf)
%   'function' function_handle (empty)
%   See also PLOT options.
%
% The IRIS Toolbox 4/18/2007. Copyright 2007 Jaromir Benes.

% function body ---------------------------------------------------------------------------------------------

[handle,range] = graph_(@stem,0,varargin{:});

end % of primary function -----------------------------------------------------------------------------------