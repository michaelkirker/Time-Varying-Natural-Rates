function this = mtimes(this,list)
% MTIMES  Intersection of two structs or struct and cellstr.

% The IRIS Toolbox 2009/02/18.
% Copyright 2007-2009 Jaromir Benes.

%********************************************************************
%! Function body.

if ischar(list)
   list = charlist2cellstr(list);
elseif isstruct(list)
   list = fieldnames(list);
end

f = vech(fieldnames(this));
c = vech(struct2cell(this));
[fnew,index] = intersect(f,list);
this = cell2struct(c(index),fnew,2);

end
% End of primary function.