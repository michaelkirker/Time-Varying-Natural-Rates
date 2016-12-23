function text = removecomments(text,varargin)
% REMOVECOMMENTS  Remove user-specified line comments and block comments.

% The IRIS Toolbox 2009/05/15.
% Copyright (c) 2007-2008 Jaromir Benes.

if nargin == 1
   % standard IRIS commments
   varargin = {{'/*','*/'},{'%{','%}'},{'<!--','-->'},'%','//'};
end

%********************************************************************
%! Function body.

for i = 1 : length(varargin)

  if ischar(varargin{i})

    % remove line comments
    text = regexprep(text,[varargin{i},'.*?\n'],'\n');
    text = regexprep(text,[varargin{i},'.*?$'],'');

  elseif iscell(varargin{i}) && length(varargin{i}) == 2

    % remove block comments
    text = strrep(text,varargin{i}{1},char(1));
    text = strrep(text,varargin{i}{2},char(2));
    textlength = NaN;
    while length(text) ~= textlength
      textlength = length(text);
      text = regexprep(text,'\x{1}[^\x{1}]*?\x{2}','');
    end
    text = strrep(text,char(1),varargin{i}{1});
    text = strrep(text,char(2),varargin{i}{2});
  
  end

end

end
% End of primary function.