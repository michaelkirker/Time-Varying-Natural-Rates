function x = cutsmall(x,realsmall,base)
%
% The IRIS Toolbox 2007/05/03. Copyright 2007 Jaromir Benes. <a href="www.iris-toolbox.com">www.iris-toolbox.com</a>
% _______________________________________________________________________________

if nargin < 3
  base = 0;
end

if nargin < 2 || isempty(realsmall)
  realsmall = getrealsmall();
end

%% function body --------------------------------------------------------------------------------------------

for i = vech(base)
  x(abs(x - i) < realsmall) = i;
end

end

%% end of primary function ----------------------------------------------------------------------------------