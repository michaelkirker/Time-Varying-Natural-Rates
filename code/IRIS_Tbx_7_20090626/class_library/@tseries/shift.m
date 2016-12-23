function this = shift(this,n)
if nargin < 2
   n = -1;
end
this.start = this.start - n;
end