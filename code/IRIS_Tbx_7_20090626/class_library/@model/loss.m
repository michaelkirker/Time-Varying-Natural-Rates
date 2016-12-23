function [L1,L2] = loss(m,Y)

try
   % Try to import Time Domain package directory.
   import('time_domain.*');
end

ny = length(m.systemid{1});
nx = length(m.systemid{2});
nf = sum(imag(m.systemid{2}) >= 0);
nb = nx - nf;
ne = length(m.systemid{3});

[T,R,K,Z,H,D,U,Omg] = sspace(m);
[nx,nb] = size(T);

% components of the loss function
Y22 = Y(nb+1:end,nb+1:end);
L1 = trace(Y22*Omg);

% Call Time Domain package.
[C,diffuse] = acovf(T,R,[],[],[],[],[],Omg,m.eigval(1,:),0);

C = C(nf+1:end,nf+1:end);
diffuse = diffuse(nf+1:end);
Y11 = Y(1:nb,1:nb);
Y11 = transpose(U)*Y11*U;
L2 = trace(Y11(~diffuse,~diffuse)*C(~diffuse,~diffuse));

end