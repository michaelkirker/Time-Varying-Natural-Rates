function [d,list] = dbremove(d,varargin)
%
% DBREMOVE  Remove fields from database.
%
% Syntax:
%   [d,list] = dbremove(d,...)
% Required input arguments:
%   d struct; list cellstr
% <a href="options.html">Optional input arguments:</a>
%   'namefilter' char|cellstr|Inf (Inf)
%   'classfilter' char|cellstr|Inf (Inf)
%
% The IRIS Toolbox 2007/05/03. Copyright 2007 Jaromir Benes. <a href="www.iris-toolbox.com">www.iris-toolbox.com</a>

%%

if ~isstruct(d)
   error('Incorrect type of input argument(s).');
end

% ===========================================================================================================
%% function body

list = dbquery(d,'','',varargin{:});
d = rmfield(d,list);

end
% end of primary function