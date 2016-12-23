function list = labelstore(p,list)

for i = 1 : length(list)
   if ~isempty(list{i})
      index = sscanf(list{i},'#%g');
      try
         list{i} = p.labels{index};
      end
   end
end

end