function this = chngnames(this,replace)

name = vech(fieldnames(this));
value = vech(struct2cell(this));

for i = 1 : length(name)
  name{i} = strrep(replace,'$0',name{i});
end

this = cell2struct(value,name,2);

end