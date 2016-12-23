function [f,mu,sigma] = snormpdf(x,Ex,Sx,tau)
%
% SNORMPDF  Probability density function for univariate split normal distribution.
%
% The IRIS Toolbox 2007/05/03. Copyright 2007 Jaromir Benes. <a href="www.iris-toolbox.com">www.iris-toolbox.com</a>

% function body ---------------------------------------------------------------------------------------------

% x ~ N(mu,sigma) for x <= mu
% x ~ N(mu,tau*sigma) for x > mu

Sx2 = Sx^2;
b = (pi-2)/pi*(tau - 1)^2 + tau;
sigma2 = Sx2/b;
sigma = sqrt(sigma2);
mu = Ex - sqrt(2/pi)*sigma*(tau - 1);

f = nan(size(x));
if ~isempty(x)
  index = x <= mu;
  f(index) = 1/(1+tau)*normpdf(x(index),mu,sigma);
  f(~index) = tau/(1+tau)*normpdf(x(~index),mu,tau*sigma);
end

end % of primary function -----------------------------------------------------------------------------------