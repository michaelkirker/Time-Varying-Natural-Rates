function x = moving_(x,window,fn)
%
% Called from within tseries/moving.
%
% The IRIS Toolbox 2007/05/10. Copyright 2007 <a href="mailto:jaromir.benes@gmail.com?subject=The%20IRIS%20Toolbox%3A%20%5Byour%20subject%5D">Jaromir Benes</a>. <a href="www.iris-toolbox.com">www.iris-toolbox.com</a>
% _______________________________________________________________________________

%% function body --------------------------------------------------------------------------------------------

window = vech(window);
if isempty(window)
  warning('Empty moving window.');
  x(:) = NaN;
else
  for i = 1 : size(x,2)
    x(:,i) = feval(fn,shift_(x(:,i),window),2);
  end
end

end

% end of primary function -----------------------------------------------------------------------------------