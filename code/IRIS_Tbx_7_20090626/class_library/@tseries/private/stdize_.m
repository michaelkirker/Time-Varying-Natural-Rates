function x = stdize_(x,flag)
%
% Called from within tseries/stdize.
%
% The IRIS Toolbox 2007/05/03. Copyright 2007 Jaromir Benes. <a href="www.iris-toolbox.com">www.iris-toolbox.com</a>
% _______________________________________________________________________________

if nargin < 2
  flag = 0;
end

%% function body --------------------------------------------------------------------------------------------

xsize = size(x);
x = x(:,:);

if flag == 0
  norm = 1;
else
  norm = 0;
end

for i = 1 : size(x,2)
  sample = ~isnan(x(:,i));
  nper = sum(sample) - norm;
  x(:,i) = x(:,i) - mean(x(sample,i));
  x(:,i) = x(:,i) / sqrt(transpose(x(sample,i))*x(sample,i)/nper);
end

x = reshape(x,xsize);

end

%% end of primary function ----------------------------------------------------------------------------------