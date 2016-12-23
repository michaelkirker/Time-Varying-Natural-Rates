function [time,name] = findoccur_(this,eq,relation,type,t)
% Find occurences of names in an equation.

% The IRIS Toolbox 2009/01/09.
% Copyright (c) 2007-2009 Jaromir Benes.

% =======================================================================================
%! Function body.

% Convert occur from sparse 2D to full 3D.
size3D = [size(this.occur,1),length(this.name),size(this.occur,2)/length(this.name)];
occur = reshape(full(this.occur),size3D);
if nargin < 5
   t = 1 : size(occur,3);
end

% Find occurences of names of desired type(s).
switch relation
case '<='
   [time,name] = find(permute(occur(eq,this.nametype <= type,t),[3,2,1]));
case '=='
   [time,name] = find(permute(occur(eq,this.nametype == type,t),[3,2,1]));
end

end
% End of primary function.