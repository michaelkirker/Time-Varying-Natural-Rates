function code = arraycode_(array,options)
%
% The IRIS Toolbox 2007/05/03. Copyright 2007 Jaromir Benes. <a href="www.iris-toolbox.com">www.iris-toolbox.com</a>

nbody = size(array.body);
if nbody(2) > 0
  %vdivider = [{''},repmat({'@{\hspace*{0.8em}}'},[1,nbody(2)-1]),{''}];
  %vdivider(vech(array.vdivider)+1) = {'@{\hspace*{0.4em}}|@{\hspace*{0.4em}}'};
  vdivider = [{''},repmat({''},[1,nbody(2)-1]),{''}];
  vdivider(vech(array.vdivider)+1) = {'|'};
  if any(array.vdivider == 0)
    vdivider(1) = {'|@{#hspace*{0.3em}}'};
  end
  if any(array.vdivider == nbody(2))
    vdivider(end) = {'@{#hspace*{0.3em}}|'};
  end
  align = cell([1,2*nbody(2)+1]);
  align(1:2:end) = vdivider(:);
  align(2:2:end) = array.align(:);
else
  align = {'l'};
end

% intertext specials
mindivider = min(array.vdivider(array.vdivider > 0));
if ~isempty(mindivider)
  multicols = sprintf('%g',mindivider);
  multieof = repmat('&',[1,nbody(2)-mindivider]);
  multiafter = '|';
else
  multicols = sprintf('%g',nbody(2));
  multieof = '';
  multiafter = '';
end
multibefore = iff(any(array.vdivider == 0),'|','');

code = sprintf('{#renewcommand{#arraystretch}{%g}\n#begin{tabular}{%s}\n',array.arraystretch,[align{:}]);
if any(array.hdivider == 0)
  code = [code,sprintf('#hline\n')];
end
for i = 1 : nbody(1)
  if ~isempty(array.intertext) && array.intertext(i) == true
    format = array.format(i,1);
    contents = sprintf(array.format{i,1},array.font{i,1},array.body{i,1});
    aux = sprintf('#multicolumn{%s}{%sl%s}{%s}%s##\n',multicols,multibefore,multiafter,contents,multieof);
    code = [code,aux];
  else
    format = cell([1,2*nbody(2)]);
    format(1:2:end) = array.format(i,:);
    format(2:2:end-2) = {'&'};
    format(end) = {'##\n'};
    contents = cell([1,2*nbody(2)]);
    contents(1:2:end) = array.font(i,:);
    contents(2:2:end) = array.body(i,:);
    aux = sprintf([format{:}],contents{:});
    code = [code,aux];
  end
  if any(array.hdivider == i)
    code = [code,sprintf('#hline\n')];
  end
end

code = strrep(code,'NaN}',sprintf('%s}',options.nan));
code = [code,sprintf('#end{tabular}}\n')];

end