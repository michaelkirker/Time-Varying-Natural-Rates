function [ph,lag] = frf2phase(w)

% function body ---------------------------------------------------------------------------------------------

warning('off','MATLAB:divideByZero');
  ph = atan2(-imag(w{1}),real(w{1}));
warning('on','MATLAB:divideByZero');

if nargout > 1
  realsmall = getrealsmall();
  lag = ph;
  for i = 1 : length(freq)
    if abs(w{2}(i)) < realsmall
      lag(:,:,i) = NaN;
    else
      lag(:,:,i) = lag(:,:,i) / w{2}(i);
    end
  end
end

end % of primary function -----------------------------------------------------------------------------------