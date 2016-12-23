function this = minus(this,list)

% ###########################################################################################################
%% function body

if ischar(list)
  list = charlist2cellstr(list);
elseif isstruct(list)
  list = fieldnames(list);
end

f = vech(fieldnames(this));
c = vech(struct2cell(this));
[fnew,index] = setdiff(f,list);
this = cell2struct(c(index),fnew,2);

end

% end of primary function
% ###########################################################################################################