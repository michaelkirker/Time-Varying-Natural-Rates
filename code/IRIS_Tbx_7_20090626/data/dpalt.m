function this = dpalt(this,index)
%
% The IRIS Toolbox 2008/08/01. Copyright (c) 2007-2008 Jaromir Benes. <a href="www.iris-toolbox.com">www.iris-toolbox.com</a>
%

% ===========================================================================================================
% function body

for i = 1 : 3
   if this{5}.mse
      this{i} = this{i}(:,:,:,index);
   else
      this{i} = this{i}(:,:,index);
   end   
end

end
% end of primary function