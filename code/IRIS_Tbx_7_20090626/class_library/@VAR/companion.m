function A = companion(this,alt)
% < a href="VAR/companion">COMPANION</a>  Transition matrix for the first-order companion form.
%
% Syntax:
%   A = companion(this)
% Output arguments:
%   A [ numeric ] First-order transition matrix.
% Required input arguments:
%   this [ VAR ] VAR model.

% The IRIS Toolbox 2009/06/23.
% Copyright 2007-2009 Jaromir Benes.

[ny,p,nalt] = size(this);

if nargin < 2
   alt = 1 : nalt;  
else
   alt = vech(alt);
end

%********************************************************************
%! Function body.

if nargin < 2
   alt = Inf;
end
if any(isinf(alt))
   alt = 1 : nalt;
elseif islogical(alt)
   alt = find(alt);
end
alt = vech(alt);

if p == 0
   A = zeros([ny,ny,length(alt)]);
else
   A = zeros([ny*p,ny*p,length(alt)]);
   for i = 1 : length(alt)
      A(:,:,i) = [this.A(:,:,alt(i));eye([ny*(p-1),ny*p])];
   end
end

end
% End of primary function.