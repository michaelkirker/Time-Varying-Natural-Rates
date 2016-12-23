function C = polyprod(A,B)
%
% The IRIS Toolbox 2007/05/03. Copyright 2007 Jaromir Benes. <a href="www.iris-toolbox.com">www.iris-toolbox.com</a>

%! 

% ===========================================================================================================
%! function body

n = size(A,1);

pa = size(A,3) - 1;
pb = size(B,3) - 1;

pc = pa + pb;
C = zeros([n,n,pc+1]);

A = cat(3,A,zeros([n,n,pc-pa]));
B = cat(3,B,zeros([n,n,pc-pb]));

for I = 0 : pc
   for J = 0 : I
      C(:,:,1+I) = C(:,:,1+I) + A(:,:,1+J) * B(:,:,1+(I-J));
   end
end

aux = find(any(any(C ~= 0,1),2));
if isempty(aux)
   C = C(:,:,1);
else
   C = C(:,:,1:aux(end));
end

end
% end of primary function