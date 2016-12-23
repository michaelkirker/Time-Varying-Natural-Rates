function output = pestruct_(this,input,range)
% PESTRUCT_  Create a struct with array and dbase with prediction errors.

% The IRIS Toolbox 2009/04/29.
% Copyright 2007-2009 Jaromir Benes.

%********************************************************************
%! Function body.

output = struct();
output.array = input;
output.dbase = struct();
template = tseries();
for i = find(this.nametype == 1)
   if this.log(i)
      input(i,:,:) = exp(input(i,:,:));
   end
   output.dbase.(this.name{i}) = ...
      replace(template,permute(input(i,:,:),[2,1,3]),range(1),this.name(i));
end

end
% End of primary function.         