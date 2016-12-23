function meta(input,metafile,output,varargin)

% The IRIS Toolbox 2009/01/16.
% Copyright (c) 2007-2009 Jaromir Benes.

%********************************************************************
%! Function body.

if strcmpi(input,output)
   error('Output file name must differ from input file name.')
end

text = file2char(input);
this = metadata.readmeta(metafile);

pattern = '\\!meta\{\s*(.*?)\s*\}\{\s*(.*?)\s*\}';
[start,finish,tokens] = regexp(text,pattern,'start','end','tokens','once');
keyNotFound = {};
cannotEval = {};
notChar = {};
while ~isempty(start)
   [replace,flag] = metadata.get(this,tokens{1:2});
   switch flag
   case 0
      if ischar(replace)
         text = [text(1:start-1),replace,text(finish+1:end)];
      else
         notChar{end+1} = sprintf('%s/%s',tokens{1:2});
      end
   case 1
      keyNotFound{end+1} = tokens{1};
   case 2
      cannotEval{end+1} = sprintf('%s/%s',tokens{1:2});
   end
   [start,finish,tokens] = regexp(text,pattern,'start','end','tokens','once');
end

if ~isempty(keyNotFound)
   warning('\nCannot find this key: "%s".',keyNotFound{:});
end

if ~isempty(cannotEval)
   warning('\nCannot evaluate this key/field: "%s".',cannotEval{:});
end

if ~isempty(notChar)
   warning('\nThis key/field does not evaluate to character string: "%s".',cannotEval{:});
end

char2file(text,output);

end
% End of primary function.