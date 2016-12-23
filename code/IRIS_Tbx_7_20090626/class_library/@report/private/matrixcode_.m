function [code,footnote] = matrixcode_(options,contents,footnote,align)
%
% The IRIS Toolbox 2007/05/03. Copyright 2007 Jaromir Benes. <a href="www.iris-toolbox.com">www.iris-toolbox.com</a>

tag = [];
data = [];
rownames = [];
colnames = [];
array = emptyarray_();

for i = 2 : length(contents)-1
  switch contents{i}.type
  case 'data'
    data = contents{i};
  case 'rownames'
    rownames = contents{i};
  case 'colnames'
    colnames = contents{i};
  case 'tag'
    tag = contents{i};
  end
end

if isempty(data), code = ''; return, end

array = data_(array,data);
[array,iscolnames] = colnames_(array,options,colnames);
[array,isrownames] = rownames_(array,options,rownames,iscolnames);

if not(isrownames)
  array.body = array.body(:,2:end);
  array.format = array.format(:,2:end);
  array.font = array.font(:,2:end);
  array.align = array.align(2:end);
end

if not(iscolnames)
  array.body = array.body(2:end,:);
  array.format = array.format(2:end,:);
  array.font = array.font(2:end,:);
end

array = divider_(array,options,iscolnames,isrownames);
array.arraystretch = options.linestretch;
code = arraycode_(array,data.options);
[code,footnote] = tagcode_(code,options,tag,footnote);
code = embrace_(code,options,align);

end

  function array = data_(array,data) % subfunction ----------------------------------------------------------

  ndata = size(data.spec);
  [array.body,array.format,array.font] = deal(cell(ndata+1));
  [nonnegative,negative] = deal(false(size(array.body)));
  negative(2:end,2:end) = data.spec < 0;
  nonnegative(2:end,2:end) = ~negative(2:end,2:end);
  array.body(2:end,2:end) = num2cell(abs(data.spec));
  array.format(nonnegative) = {sprintf('{%%s{#hspace*{#minussignwidth}%%.%gf}}',data.options.decimal)};
  array.format(negative) = {sprintf('{%%s{--%%.%gf}}',data.options.decimal)};
  array.font(2:end,2:end) = {''};
  array.align = [{'l'},repmat({'r'},[1,ndata(2)])];

  % top-left cell
  array.body(1,1) = {''};

  end % of subfunction --------------------------------------------------------------------------------------

  function [array,iscolnames] = colnames_(array,parentoptions,colnames) % subfunction -----------------------

  if isempty(colnames)
    iscolnames = false;
    return
  end

  ndata = size(array.body) - 1;
  if length(colnames.spec) < ndata(2)
    colnames.spec = [colnames.spec,repmat({''},[1,ndata(2)-length(colnames.spec)])];
  else
    colnames.spec = colnames.spec(1:ndata(2));
  end
  colnames.spec = letterchk_(colnames.spec,colnames.options);
  try len = cellfun(@length,colnames.spec);
    catch len = cellfun('length',colnames.spec); end
  empty = (len == 0);
  iscolnames = any(not(empty));

  array.body(1,2:end) = colnames.spec(:);
  aux = repmat({'#begin{rotate}{90}%s{%s}#end{rotate}'},[1,ndata(2)]);
  aux(empty) = {'{%s{%s}}'};
  array.format(1,:) = [{'{%s{%s}}'},aux];
  aux = repmat({font_(parentoptions,colnames.options)},[1,ndata(2)]);
  aux(empty) = {''};
  array.font(1,:) = [{''},aux];

  % make column height sufficient
  aux = font_(parentoptions,colnames.options);
  insert = '';
  for i = 1 : length(colnames.spec)
    insert = [insert,sprintf('#settowidth{#ruleheight}{{%s{%s}}# }#rule{0pt}{#ruleheight}',aux,colnames.spec{i})];
  end
%insert = sprintf('#settowidth{#ruleheight}{{%s{%s}}# }#rule{0pt}{#ruleheight}',aux,long);
  array.format{1,2} = [insert,array.format{1,2}];

  end % of subfunction --------------------------------------------------------------------------------------

  function [array,isrownames] = rownames_(array,parentoptions,rownames,iscolnames) % subfunction ------------

  if isempty(rownames)
    isrownames = false;
    return
  end

  ndata = size(array.body) - 1;
  if length(rownames.spec) < ndata(1)
    rownames.spec = [rownames.spec,repmat({''},[1,ndata(1)-length(rownames.spec)])];
  else
    rownames.spec = rownames.spec(1:ndata(1));
  end
  rownames.spec = letterchk_(rownames.spec,rownames.options);
  try, empty = cellfun(@isempty,rownames.spec);
    catch, empty = cellfun('isempty',rownames.spec); end
  isrownames = any(not(empty));

  array.body(2:end,1) = rownames.spec(:);
  aux = repmat({'{%s{%s}}'},[ndata(1),1]);
  array.format(2:end,1) = aux(:);
  aux = repmat({font_(parentoptions,rownames.options)},[ndata(1),1]);
  aux(empty) = {''};
  array.font(2:end,1) = aux(:);

  end % of subfunction --------------------------------------------------------------------------------------

  function array = divider_(array,options,iscolnames,isrownames) % subfunction ------------------------------

  nbody = size(array.body);
  array.hdivider = options.hdivider;
  if options.hframe == true
    array.hdivider = unique([array.hdivider,0,double(iscolnames),nbody(1)]);
  end
  array.hdivider(array.hdivider < 0 | array.hdivider > nbody(1)) = [];
  array.vdivider = options.vdivider;
  if options.vframe == true
    array.vdivider = unique([array.vdivider,0,double(isrownames),nbody(2)]);
  end
  array.vdivider(array.vdivider < 0 | array.vdivider > nbody(2)) = [];

  end % of subfunction --------------------------------------------------------------------------------------