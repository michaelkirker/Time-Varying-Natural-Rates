function text = grabtext(startTag,endTag)

text = '';
stack = dbstack('-completenames');
if length(stack) < 2
   return
end

file = file2char(stack(2).file);
file = strrep(file,char(13),'');
tokens = regexp(file,[startTag,'\n(.*?)\n',endTag],'once','tokens');
if ~isempty(tokens)
   text = tokens{1};
end

end