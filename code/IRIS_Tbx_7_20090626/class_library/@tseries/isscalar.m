function flag = isscalar(x)

if ndims(x.data) == 2 && size(x.data,2) == 1, flag = true;
  else flag = false; end

end