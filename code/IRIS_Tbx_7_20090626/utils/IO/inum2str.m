function s = inum2str(x,tol)

[nr,nc] = size(x);
iscmplx = any(imag(x) ~= 0,1);

re = sprintf('%12.5g',(real(transpose(x))));
re = transpose(reshape(transpose(re),[nc*12,nr]));
im = sprintf('%12.5gi',abs(imag(transpose(x(:,iscmplx)))));
im = transpose(reshape(transpose(im),[sum(iscmplx)*13,nr]));
signim = sign(imag(x));
[i,j] = find(imag(x(:,iscmplx)) == 0);
for ix = 1 : length(i)
  im(i(ix),j(ix)+(0:12)) = ' ';
end
keyboard
s = '';
for r = 1 : nr
  row = '';
  for c = 1 : nc
    row = [row,' ',sprintf_(real(x(r,c)),false)];
    if iscmplx(c) == true
      row = [row,' ',sprintf_(imag(x(r,c)),true)];
    end
  end
  s = [s;row];
end

end % of primary function -----------------------------------------------------------------------------------

function s = sprintf_(x,flag) % subfunction -----------------------------------------------------------------
if flag == true
  if x == 0
    s = blanks(14);
    return
  end
  s = sprintf('%12.6gi',abs(x));
else
  s = sprintf('%12.6g',abs(x));
end
if sign(x) < 0
  s = ['-',s];
else
  if flag == true
    s = ['+',s];
  else
    s = [' ',s];
  end
end
end % of subfunction ----------------------------------------------------------------------------------------