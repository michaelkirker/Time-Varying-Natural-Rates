function c = pdlcoeff(p,lags,scale)

if nargin < 3
  scale = 1;
end

p = vech(p);
nPowers = length(p);
order = nPowers-1;

lags = vech(lags);
nLags = length(lags);

lags = lags(ones([1,nPowers]),:);
powers = transpose(0 : order);
powers = powers(:,ones([1,nLags]));
x = lags .^ powers * scale;

c = p * x;

end