function this = loadobj(this)
if isstruct(this)
  this = tseries(this);
end
end