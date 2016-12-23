function varargout = size(w)

[ny,aux,nalt] = size(w.A);
if ny == 0
  p = 0;
else
  p = aux/ny;
end

if nargout == 1
  varargout{1} = [ny,p,nalt];
else
  varargout(1:3) = {ny,p,nalt};
end

end