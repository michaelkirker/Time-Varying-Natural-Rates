function [code,footnote] = tagcode_(code,parentoptions,tag,footnote)

if isempty(tag)
  return
end
  
tag.spec = letterchk_(tag.spec,tag.options);
if ~isempty(tag.spec)
  if ~isempty(tag.options.footnote)
    footnote{end+1} = letterchk_(tag.options.footnote,tag.options);
    footnotemark = '#footnotemark';
  else
    footnotemark = '';
  end
  code = sprintf('{#begin{tabular}{c}{%s{%s%s}}##[4pt]\n%s#end{tabular}}\n',font_(parentoptions,tag.options),tag.spec,footnotemark,code);
end

end