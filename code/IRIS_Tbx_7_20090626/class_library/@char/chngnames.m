function this = chngnames(this,replace)

% catch labels closed in single or double quotes
labels = {};
quotes = {};
[match,start,finish] = regexp(this,'[''"][^''"].*?[''"]','match','start','end','once');
while ~isempty(match)
   labels{end+1} = match;
   this = [this(1:start-1),char(0),this(finish+1:end)];
   [match,start,finish] = regexp(this,'[''"][^''"].*?[''"]','match','start','end','once');
end

this = removecomments(this);
this = regexprep(this,'(?<![!@:])\<[a-zA-Z]\w*\>(?!\()',replace);

% put comments back
start = regexp(this,'\x0','start','once');
while ~isempty(start) && ~isempty(labels)
   this = [this(1:start-1),labels{1},this(start+1:end)];
   start = regexp(this,'\x0','start','once');
   labels(1) = [];
end

end