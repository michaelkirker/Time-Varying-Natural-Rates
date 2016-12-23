function [P,Q] = factor_(A,K,Omega,y0,n)
%
% VAR/PRIVATE/FACTOR_  VAR Cholesky factor with fixed initial condition.
%
% IR!S Toolbox November 12, 2005 

% -----function FACTOR_ body----- %

[ny,aux] = size(A);
p = aux/ny;

P = zeros([ny,ny*(n+p),n+p]);
Q = zeros([ny,n+p]);
Q(:,1:p) = y0;
A = reshape(A,[ny,ny,p]);
B = transpose(chol(Omega));
for t = p + (1 : n)
  P(:,(t - 1)*ny + (1 : ny),t) = B;
  Q(:,t) = K;
  for i = 1 : p
    P(:,:,t) = P(:,:,t) + A(:,:,i)*P(:,:,t-i);
    Q(:,t) = Q(:,t) + A(:,:,i)*Q(:,t-i);
  end  
end
P = transpose(reshape(permute(P,[2,1,3]),[ny*(n+p),ny*(n+p)]));
P = P(ny*p+1:end,ny*p+1:end);
Q = vec(Q(:,p+1:end));

end