function [arglist,value] = getoption(arglist,name,default)

index = find(strcmpi(name,arglist));
if ~isempty(index)
  value = arglist{index(end)+1};
  arglist([index,index+1]) = [];
else
  value = default;
end

end