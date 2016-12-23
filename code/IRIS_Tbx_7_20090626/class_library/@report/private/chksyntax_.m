function chksyntax_(parenttype,type)

switch parenttype
case 'report'
  list = {'begintable','beginalign','beginmatrix','begingraph','begintext',...
        'title','newpage','skip',...
        'compile'};
case 'begingraph'
  list = {'tag',...
        'endgraph'};
case 'begintable'
  list = {'row','intertext','tag',...
        'endtable'};
case 'beginmatrix'
  list = {'data','rownames','colnames','tag',...
        'endmatrix'};
case 'begintext'
  list =  {'paragraph','tex','tag',...
        'endtext'};
case 'beginalign'
  list = {'begintable','begintext','beginmatrix',...
        'opengraph','getgraph','title','breakalign',...
        'endalign'};
end

if all(not(strcmp(list,type)))
  error_(2,{type});
end

end