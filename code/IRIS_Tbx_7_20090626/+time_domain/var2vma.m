function Phi = var2vma(A,B,nper)
%
% TIME-DOMAIN/VAR2VMA Convert VAR to VMA.
%
% The IRIS Toolbox 2007/07/18. Copyright 2007 Jaromir Benes. <a href="http://www.iris-toolbox.com">www.iris-toolbox.com</a>
%

%! 

if ~isnumeric(nper)
   error('Incorrect type of input argument(s).');
end

% ===========================================================================================================
%! function body

[ny,p,nalt] = size(A);
p = p/ny;
A = reshape(A,[ny,ny,p,nalt]);

Phi = zeros([ny,ny,nper,nalt]);
for ialt = 1 : nalt
   if isempty(B)
      Phi(:,:,1,ialt) = eye(ny);
   else
      if isempty(B)
         Phi(:,:,1,ialt) = eye(ny);
      else
         Phi(:,:,1,ialt) = B(:,:,ialt);
      end
   end
   for t = 2 : nper
      for k = 1 : min([p,t-1])
         Phi(:,:,t,ialt) = Phi(:,:,t,ialt) + A(:,:,k,ialt)*Phi(:,:,t-k,ialt);
      end
   end
end

end
% end of primary function