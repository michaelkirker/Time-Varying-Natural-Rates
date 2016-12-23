function [match,index,tokens] = query(list,varargin)
%
% QUERY  Names from list or database to match desired pattern.
%
% Syntax:
%   [match,index,tokens] = query(d,pattern)
%   [match,index,tokens] = query(list,pattern)
% Arguments:
%   match cellstr; index logical; tokens cell; d struct; list cellstr; pattern char
%
% The IRIS Toolbox 2007/05/03. Copyright 2007 Jaromir Benes. <a href="www.iris-toolbox.com">www.iris-toolbox.com</a>

if length(varargin) == 1
   namePattern = varargin{1};
end

if nargin < 3
   classPattern = '';
end

if isstruct(list)
   list = vech(fieldnames(list));
end

if ~iscellstr(list) || (~ischar(namePattern) && ~isempty(namePattern)) || (~ischar(classPattern) && ~isempty(classPattern))
   error('Incorrect type of input argument(s).');
end

% ===========================================================================================================
%% function body

tokens = cell([1,0]);
[match,tokens] = regexp(list,namePattern,'match','tokens','once');
index = strcmp(match,list);
match = match(index);
tokens = tokens(index);

end
% end of primary function