function code = skipcode_(contents)

list = {'small','med','big'};
if all(~strcmp(contents.spec,list))
  contents.spec = 'med';
end

code = sprintf('#%sskip#%sskip#par\n',contents.spec,contents.spec);

end