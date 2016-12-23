function x = fixcov(x)
% Remove negative diagonal entries from covariance matrices occurring due to numerical inaccuracy.

% The IRIS Toolbox 2008/09/10.
% Copyright (c) 2007-2008 Jaromir Benes.

% =======================================================================================
%! Function body.

tol = getrealsmall('mse');
for i = 1 : size(x,4)
   for j = 1 : size(x,3)
      index = abs(diag(x(:,:,j,i))) < tol; % small or negative
      if any(index)
         x(index,index,j,i) = 0;
      end
   end
end

end
% End of primary function.