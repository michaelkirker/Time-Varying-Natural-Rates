function x = df_(x,s)
%
% Called from within tseries/diff.
%
% The IRIS Toolbox 2007/10/25. Copyright 2007 Jaromir Benes. <a href="http://www.iris-toolbox.com">www.iris-toolbox.com</a>
% _______________________________________________________________________________

if nargin < 2
  s = -1;
end

%% function body --------------------------------------------------------------------------------------------

s = vech(s);
index = transpose(1:size(x,2));
index = index(:,ones([1,length(s)]));
index = transpose(index(:));
x = x(:,index) - shift_(x,s);

end

%% end of primary function ----------------------------------------------------------------------------------