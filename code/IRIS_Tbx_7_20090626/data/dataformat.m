function flag = dataformat(x)

if iscell(x) || (isfield(x,'mean') && iscell(x.mean))
   flag = 'dpack';
elseif isstruct(x) || (isfield(x,'mean') && isstruct(x.mean))
   flag = 'dbase';
elseif isnumeric(x)
   flag = 'array';
else
   flag = 'unknown';
end

end