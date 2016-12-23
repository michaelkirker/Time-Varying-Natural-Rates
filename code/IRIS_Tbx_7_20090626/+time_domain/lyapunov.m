function C = lyapunov(T,Sigma,beta)
%
% TIME-DOMAIN/LYAPUNOV  Solve Lyapunov equation.
% C = beta*T*C*T' + Sigma, with T quasi-triangular
%
% The IRIS Toolbox 2007/05/03. Copyright 2007 Jaromir Benes. <a href="www.iris-toolbox.com">www.iris-toolbox.com</a>

%! 

% ===========================================================================================================
%! function body

% discounted equation
if nargin > 2
   T = sqrt(beta)*T;
end

C = zeros(size(T));
i = size(T,1);
Tprime = transpose(T);
while i >= 1
   if i == 1 || T(i,i-1) == 0 % real eigenvalue
      C(i,i+1:end) = transpose(C(i+1:end,i));
      aux = (Sigma(i,1:i) + T(i,i)*C(i,i+1:end)*Tprime(i+1:end,1:i) + ...
      T(i,i+1:end)*C(i+1:end,:)*Tprime(:,1:i)) / (eye(i) - T(i,i)*Tprime(1:i,1:i));
      C(i,1:i) = aux;
      i = i - 1;
   else % pair of complex eigenvalue
      C(i-1:i,i+1:end) = transpose(C(i+1:end,i-1:i));
      aux = vec(T(i-1:i,i-1:i)*C(i-1:i,i+1:end)*Tprime(i+1:end,1:i) + ...
      T(i-1:i,i+1:end)*C(i+1:end,:)*Tprime(:,1:i) + Sigma(i-1:i,1:i));
      aux = reshape((eye(2*i) - kron(transpose(Tprime(1:i,1:i)),T(i-1:i,i-1:i))) \ aux,[2,i]);
      C(i-1:i,1:i) = aux;
      i = i - 2;
   end
end

end
% end of primary function
