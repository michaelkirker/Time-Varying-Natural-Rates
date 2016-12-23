function this = refresh(this,alt)
% REFRESH  Refresh steady state and parameters using dynamic links.

% The IRIS Toolbox 2009/04/09.
% Copyright 2007-2009 Jaromir Benes.

if isempty(this.refresh)
   return
end

nalt = size(this.assign,3);
if nargin > 1
   alt = vech(alt);
   if any(isinf(alt))
      alt = 1 : nalt;
   elseif islogical(alt)
      alt = find(alt);
   end
else
   alt = 1 : nalt;
end

%********************************************************************
%! Function body.

offset = sum(this.eqtntype < 4);
for ialt = alt
   x = this.assign(1,:,ialt);
   % We cannot use cellfuns
   % because dynamic links can be recursive.
   for j = this.refresh
      x(1,j) = feval(this.eqtnF{offset+j},x,1);
   end
   this.assign(1,:,ialt) = x;
end

end
% End of primary function.