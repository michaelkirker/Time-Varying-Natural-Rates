function [value,flag] = getmeta(this,key,field)

index = find(strcmp(key,this.key));
if isempty(index)
   value = NaN;
   flag = 1;
else
   try
      value = this.data{index}.(field);      
      flag = 0;
   catch
      value = NaN;;
      flag = 2;
   end
end

end