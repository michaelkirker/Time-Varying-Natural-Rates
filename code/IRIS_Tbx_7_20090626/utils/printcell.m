function prt = printcell(cellArray)

prt = '';
for i = 1 : length(cellArray)
  if isnumeric(cellArray{i})
    prt = [prt,'  ',num2str(cellArray{1,i}),''];
  else
    prt = [prt,'  ''',cellArray{1,i},''''];
  end
end
if length(prt) > 0
  prt = prt(3:end);
end

return