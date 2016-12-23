function a = array_(s)

n = length(s);
rep = cell([1,n]);
for I = 1 : n
  rep{I} = ones([1,s(I)]);
end
a = tseries;
a = a(rep{1:end});

return  