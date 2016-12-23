function y = shift_(x,s)
%
% The IRIS Toolbox 2007/05/03. Copyright 2007 Jaromir Benes. <a href="www.iris-toolbox.com">www.iris-toolbox.com</a>
% _______________________________________________________________________________

if nargin < 2
  s = -1;
end

%% function body --------------------------------------------------------------------------------------------

s = vech(s);
xsize = size(x);
x = x(:,:);
nx = size(x,2);
y = [];
for k = vech(s)
  if k > 0
    tmp = [x(1+k:end,:);NaN*ones([k,nx])];
  elseif k < 0
    tmp = [NaN*ones([-k,nx]);x(1:end+k,:)];
  else 
    tmp = x;
  end
  y = [y,reshape(tmp,xsize)];
end

end

% end of primary function -----------------------------------------------------------------------------------