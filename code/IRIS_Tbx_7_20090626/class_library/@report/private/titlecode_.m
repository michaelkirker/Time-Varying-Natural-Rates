function [code,footnote] = titlecode_(contents,footnote,align)

contents.options.footnote = letterchk_(contents.options.footnote,contents.options);
if ~isempty(contents.options.footnote)
  footnote{end+1} = contents.options.footnote;
  footnotemark = '#footnotemark';
else
  footnotemark = '';
end

code = sprintf('{%s%s}',letterchk_(contents.spec,contents.options),footnotemark);
code = embrace_(code,contents.options,align);

end