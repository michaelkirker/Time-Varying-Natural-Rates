function [min_interval] = hpd(x2,prob)
% computes minimum probability interval from posterior draws
  
  n = size(x2,1);
  np = size(x2,2);
  n1 = round((1-prob)*n);
  k = zeros(n1,1);
  for i = 1:np
    x3 = sort(x2(1:end,i));
  
    j2 = n-n1;
    for j1 = 1:n1
      k(j1) = x3(j2)-x3(j1);
      j2 = j2 + 1;
    end
    
    [kmin,k1] = min(k);
    
    min_interval(i,:) = [x3(k1) x3(k1)+kmin];
  end
  