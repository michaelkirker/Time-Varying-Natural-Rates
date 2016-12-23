function x = pct_(x,s)
%
% Called from within tseris/pct.
%
% The IRIS Toolbox 2007/10/25. Copyright 2007 Jaromir Benes. <a href="http://www.iris-toolbox.com">www.iris-toolbox.com</a>
% _______________________________________________________________________________

if nargin < 2
  s = -1;
end

%% function body --------------------------------------------------------------------------------------------

s = transpose(s(:));
index = transpose(1:size(x,2));
index = index(:,ones([1,length(s)]));
index = transpose(index(:));
x = 100*(x(:,index) ./ shift_(x,s) - 1);

end

% end of primary function -----------------------------------------------------------------------------------