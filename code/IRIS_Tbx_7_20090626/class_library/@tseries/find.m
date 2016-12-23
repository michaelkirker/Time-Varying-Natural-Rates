function index = find(x,varargin)

[x.data,dim] = reshape_(x.data);
index = {};
for i = 1 : size(x.data,2), index{end+1} = x.start + find(x.data(:,i)) - 1; end
if size(x.data,2) == 1, index = index{1};
  else index = reshape(index,[1,dim]); end

end