function [code,footnote] = textcode_(options,contents,footnote,align);

code = sprintf('#begin{minipage}{%g#textwidth}#setlength{#parskip}{0.5#baselineskip}\n',options.textwidth);

tag = [];
for i = 2 : length(contents)-1
  switch contents{i}.type
  case 'paragraph'
    code = [code,paragcode_(options,contents{i})];
  case 'tex'
    code = [code,texcode_(options,contents{i})];
  case 'tag'
    tag = contents{i};
  end
end

code = sprintf('%s\n#end{minipage}\n',code);
[code,footnote] = tagcode_(code,options,tag,footnote);
code = embrace_(code,options,align);

end

  % -----subfunction----- %
  
  function code = paragcode_(options,parag)
  
  font = font_(options,parag.options);
  code = sprintf('{%s%s{#renewcommand{#baselinestretch}{%g}%s#par}}\n',iff(parag.options.centering,'#centering',''),font,parag.options.linestretch,letterchk_(parag.spec,parag.options));
  
  end
  
  % -----subfunction----- %
  
  function code = texcode_(options,tex)
  
  font = font_(options,tex.options);
  code = sprintf('{%s#par}\n',font,tex.spec);
  
  end