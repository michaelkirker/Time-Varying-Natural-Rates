function flag = isnumericscalar(x)
flag = isnumeric(x) && length(x) == 1;
end