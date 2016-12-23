function flag = chkdpack(this,dpack)

if isfield(dpack,'mean')
   dpack = dpack.mean;
end

yvector = get(this,'yvector');
xvector = get(this,'xvector');
evector = get(this,'evector');
flag = ...
   isequal(yvector,dpack{5}.yvector) && ...
   isequal(xvector,dpack{5}.xvector) && ...
   isequal(evector,dpack{5}.evector);

end