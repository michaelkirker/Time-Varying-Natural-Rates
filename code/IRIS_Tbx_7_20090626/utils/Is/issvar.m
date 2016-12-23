function flag = issvar(x)
flag = isvar(x) && ~isempty(x.B);
end