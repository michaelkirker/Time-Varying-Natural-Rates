function multiwarning(format,list)

if isempty(list)
  return
end

formats = cell(size(list));
formats{1} = [format,'\n'];
formats(2:end-1) = {['         ',format,'\n']};
formats{end} = ['         ',format];
warning([formats{:}],list{:});

end