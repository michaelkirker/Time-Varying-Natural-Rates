function range = range_(x)
nper = size(x.data,1);
if nper == 0
  range = [];
else
  range = x.start + (0 : nper - 1);
end
end