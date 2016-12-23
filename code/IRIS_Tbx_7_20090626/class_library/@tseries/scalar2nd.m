function this = scalar2nd(this,newsize)

thissize = size(this.data);
if length(thissize) > 2 || thissize(2) > 1
   return
end
n = prod(newsize(2:end));
this.data = this.data(:,ones([1,n]));
this.data = reshape(this.data,[thissize(1),newsize(2:end)]);
this.comment = this.comment(1,ones([1,n]));
this.comment = reshape(this.comment,[1,newsize(2:end)]);

end