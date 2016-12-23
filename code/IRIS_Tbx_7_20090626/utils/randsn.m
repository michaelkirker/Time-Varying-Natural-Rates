function r = randsn(dim,Ex,Sx,tau)
%
% RANDSN  Split-normally distributed random numbers.
%
% The IRIS Toolbox 2007/05/03. Copyright 2007 Jaromir Benes. <a href="www.iris-toolbox.com">www.iris-toolbox.com</a>

% function body -----------------------------------------------------------------------------------

[ans,mu,sigma] = snormpdf([],Ex,Sx,tau);

r = sigma*randn(dim);
index = rand(dim) <= 1/(1 + tau);
r(index) = -abs(r(index));
r(~index) = tau*abs(r(~index));
r = r + mu;

end % of primary function -----------------------------------------------------------------------------------