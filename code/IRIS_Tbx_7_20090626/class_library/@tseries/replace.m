function x = replace(x,data,start,comment)

x.data = data;
if nargin > 2
   x.start = start;
end
if nargin > 3 && (iscell(comment) || ischar(comment)) 
   if iscell(comment)
      x.comment = comment;
   else
      x.comment = {comment};
   end
else
   si = size(x.data);
   x.comment = cell([1,si(2:end)]);
   x.comment(:) = {''};
end
x = cut_(x);

end