function [code,footnote] = tablecode_(options,contents,footnote,align)

config = irisconfig();

nrange = length(options.range);
nsstate = nnz(options.sstate);
tag = [];
array = emptyarray_();
dateformat = iff(any(isinf(options.dateformat)),config.dateformat,options.dateformat);
array.body = [{''},{''},dat2str(options.range,dateformat),iff(options.sstate,{options.sstatemark},{})];
array.format = repmat({'{%s{%s}}'},[1,2+nrange+nsstate]);
array.font = [{''},{''},repmat({font_(options,options)},[1,nrange+nsstate])];
array.align = [{'l'},{'l'},repmat({'r'},[1,nrange+nsstate])];
array.intertext(end+1) = false;

for i = 2 : length(contents)-1
  switch contents{i}.type
  case 'row'
    [array,footnote] = row_(array,options,contents{i},footnote);
  case 'intertext'
    [array,footnote] = intertext_(array,options,contents{i},footnote);
  case 'tag'
    tag = contents{i};
  end   
end

array = divider_(array,options);
array.arraystretch = options.linestretch;
code = arraycode_(array,options);
[code,footnote] = tagcode_(code,options,tag,footnote);
code = embrace_(code,options,align);

end

  % -----subfunction----- %
  
  function [array,footnote] = row_(array,parentoptions,row,footnote)
  
  row.options.text = letterchk_(row.options.text,row.options);
  row.options.unit = letterchk_(row.options.unit,row.options);
  if ~isempty(row.options.footnote)
    footnote{end+1} = letterchk_(row.options.footnote,row.options);
    footnotemark = '#footnotemark';
  else
    footnotemark = '';
  end
    
  nrange = length(parentoptions.range);
  nsstate = nnz(parentoptions.sstate);
  sstate = iff(parentoptions.sstate,row.options.sstate,[]);
  numeric = [transpose(double(row.spec,parentoptions.range)),sstate];
  [nonnegative,negative] = deal(false([1,2+nrange+nsstate]));
  negative(3:end) = numeric < 0;
  nonnegative(3:end) = ~negative(3:end);
  array.body(end+1,:) = [{[row.options.text,footnotemark]},{row.options.unit},num2cell(abs(numeric))];
  aux = [{'{%s{%s}}'},{'{%s{%s}}'},cell([1,nrange+nsstate])];
  aux(nonnegative) = {sprintf('{%%s{#hspace*{#minussignwidth}%%.%gf}}',row.options.decimal)};
  aux(negative) = {sprintf('{%%s{--%%.%gf}}',row.options.decimal)};
  array.format(end+1,:) = aux;
  aux = repmat({font_(parentoptions,row.options)},[1,2+nrange+nsstate]);
  array.font(end+1,:) = aux;
  array.intertext(end+1) = false;

  end

  % -----subfunction----- %
  
  function [array,footnote] = intertext_(array,parentoptions,intertext,footnote)
  
  intertext.options.text = letterchk_(intertext.options.text,intertext.options);
  if ~isempty(intertext.options.footnote)
    footnote{end+1} = letterchk_(intertext.options.footnote,intertext.options);
    footnotemark = '#footnotemark';
  else
    footnotemark = '';
  end
  
  nrange = length(parentoptions.range);
  nsstate = nnz(parentoptions.sstate);
  aux = [{sprintf('%s%s',intertext.spec,footnotemark)},repmat({''},[1,1+nrange+nsstate])];
  array.body = [array.body;aux];
  aux = [{'{%s{%s}}'},repmat({''},[1,1+nrange+nsstate])];
  array.format = [array.format;aux];
  aux = [{font_(parentoptions,intertext.options)},repmat({''},[1,1+nrange+nsstate])];
  array.font = [array.font;aux];
  array.intertext(end+1) = true;

  end
  
  % -----subfunction----- %
  
  function array = divider_(array,options)

  nsstate = nnz(options.sstate);
  nbody = size(array.body);
  array.hdivider = options.hdivider;
  if options.hframe == true
    array.hdivider = unique([array.hdivider,0,1,nbody(1)]);
  end
  array.hdivider(array.hdivider < 0 | array.hdivider > nbody(1)) = [];
  array.vdivider = options.vdivider;
  if options.vframe == true
    array.vdivider = unique([array.vdivider,0,nbody(2),nbody(2)-nsstate]);
  end
  if ~isempty(options.divider)
    array.vdivider = unique([array.vdivider,3+round(options.divider-options.range(1))]);
  end
  array.vdivider(array.vdivider < 0 | array.vdivider > nbody(2)) = [];
  
  end
