function dates = setdates(dates)

if any(isinf(dates)), dates = x.start + (0 : size(x.data,1) - 1);
  else, dates = vech(dates); end

end