function list = dbobjects(d,classfilter)
%
% DBOJBECTS  List of database entries of given class.
%
% Syntax:
%   list = dbobjects(d,classfilter)
% Required input arguments:
%   list cellstr; d struct; classfilter char
%
% The IRIS Toolbox 2007/05/03. Copyright 2007 Jaromir Benes. <a href="www.iris-toolbox.com">www.iris-toolbox.com</a>

if nargin < 2, classfilter = 'tseries'; end

% function body ---------------------------------------------------------------------------------------------

if ~isstruct(d), list = {}; return, end

list = fieldnames(d);
if strcmp(classfilter,'float'), index = cellfun('isclass',struct2cell(d),'double') | cellfun('isclass',struct2cell(d),'single');
  else, index = cellfun('isclass',struct2cell(d),classfilter); end
list = vech(list(index));

end % of primary function -----------------------------------------------------------------------------------