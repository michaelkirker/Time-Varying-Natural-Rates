function x = dot_(x,s)
%
% Called from within tseries/dot.
%
% The IRIS Toolbox 2007/10/23. Copyright 2007 Jaromir Benes. <a href="http://www.iris-toolbox.com">www.iris-toolbox.com</a>

%! 

if nargin < 2
   s = -1;
end

% ===========================================================================================================
%! function body

s = vech(s);
index = transpose(1:size(x,2));
index = index(:,ones([1,length(s)]));
index = transpose(index(:));
x = log(x(:,index)) - log(shift_(x,s));

end
% end of primary function