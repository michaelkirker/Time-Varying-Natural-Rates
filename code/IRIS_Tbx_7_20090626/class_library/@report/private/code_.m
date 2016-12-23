function [code,reportoptions,epsfile] = code_(x)

code = '';
reportoptions = x.parentoptions{1};
epsfile = {};

i = 1;
align = false;
footnote = {};
while i <= length(x.contents)
  switch x.contents{i}.type
  case 'beginalign'
    [blockcode,alignmax] = beginaligncode_(x.contents{i}.options);
    code = [code,blockcode];
    align = true;
    aligncount = 0;
    i = i + 1;
  case 'endalign'
    blockcode = endaligncode_();
    code = [code,blockcode];
    align = false;
    emptyfootnote_();
    i = i + 1;
  case 'begintable'
    [options,contents] = getblock_('table');
    [blockcode,footnote] = tablecode_(options,contents,footnote,align);
    code = [code,blockcode];
    if align, aligndivider_(); footcode = '';
      else, footcode = emptyfootnote_(); end
    if ~isempty(contents{1}.options.saveas), saveas_(contents,blockcode,footcode); end
  case 'beginmatrix'
    [options,contents] = getblock_('matrix');
    [blockcode,footnote] = matrixcode_(options,contents,footnote,align);
    code = [code,blockcode];
    if align, aligndivider_(); footcode = '';
      else, footcode = emptyfootnote_(); end
    if ~isempty(contents{1}.options.saveas), saveas_(contents,blockcode,footcode); end
  case 'begingraph'    
    [options,contents] = getblock_('graph');
    [blockcode,footnote] = graphcode_(options,contents,footnote,align);
    code = [code,blockcode];
    if align, aligndivider_(); footcode = '';
      else, footcode = emptyfootnote_(); end
    if ~isempty(contents{1}.options.saveas), saveas_(contents,blockcode,footcode);
      else epsfile{end+1} = contents{end}.spec{1}; end
  case 'begintext'
    [options,contents] = getblock_('text');
    [blockcode,footnote] = textcode_(options,contents,footnote,align);
    code = [code,blockcode];
    if align, aligndivider_();
      else, emptyfootnote_(); end
  case 'newpage'
    blockcode = newpagecode_();
    emptyfootnote_();
    code = [code,blockcode];
    i = i + 1;
  case 'skip'
    blockcode = skipcode_(x.contents{i});
    code = [code,blockcode];
    i = i + 1;
  case 'title'
    [blockcode,footnote] = titlecode_(x.contents{i},footnote,align);
    code = [code,blockcode];
    i = i + 1;
    if align, aligndivider_();
      else, emptyfootnote_(); end
  case 'breakalign'
    i = i + 1;
  end
end

  % -----nested function----- %

  function [options,contents] = getblock_(type)
  
  endblock = sprintf('end%s',type);
  options = x.contents{i}.options;
  contents = {};
  while ~strcmp(x.contents{i}.type,endblock)
    contents{end+1} = x.contents{i};
    i = i + 1;
  end
  contents{end+1} = x.contents{i};
  i = i + 1;
  
  end
  
  % -----nested function----- %
  
  function aligndivider_()
  
  aligncount = aligncount + 1;
  if strcmp(x.contents{i}.type,'endalign'), return, end
  if aligncount < alignmax && ~strcmp(x.contents{i}.type,'breakalign'), code = [code,sprintf('&\n')];
    else, aligncount = 0; code = [code,sprintf('\\\\ \\\\\n')]; end
  
  end
  
  % -----nested function----- %
  
  function footcode = emptyfootnote_()

  footcode = '';
  if ~isempty(footnote)
    n = length(footnote);
    footcode = [footcode,sprintf('\\addtocounter{footnote}{%g}\n',-n+1)];
    if n > 1
      footcode = [footcode,sprintf('\\footnotetext{%s}\\addtocounter{footnote}{1}\n',footnote{1:end-1})];
    end
    footcode = [footcode,sprintf('\\footnotetext{%s}\n',footnote{end})];
    footnote = {};
  end
  code = [code,footcode];
  
  end
  
end