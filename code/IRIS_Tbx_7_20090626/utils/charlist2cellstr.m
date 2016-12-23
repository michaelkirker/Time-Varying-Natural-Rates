function [strings,labels] = charlist2cellstr(x,sep)
% Convert list in character string to cell array of strings.

% The IRIS Toolbox 2008/10/14.
% Copyright (c) 2007-2008 Jaromir Benes.

if nargin < 2
   sep = ',;\n';
end

% =======================================================================================
%! Function body.

x = strtrim(x);
x = strrep(x,char(13),'');
x = removecomments(x,{'/*','*/'},{'%{','%}'},{'<!--','-->'},'%','//');

% separators , ; end-of-line
pattern = '(?<label>["''].*?["''])?\s*(?<string>[^"''#]*?)\s*(?=[#]|$)';
pattern = strrep(pattern,'#',sep);
y = regexp(x,pattern,'names');
strings = {y(:).string};
labels = {y(:).label};
% remove double quotes from labels
for i = 1 : length(labels)
   labels{i} = labels{i}(2:end-1);
end

end
% End of primary function.