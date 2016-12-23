function disp(this)

if ~isempty(this.userdata)
   tmpsize = sprintf('%gx',size(this.userdata));
   tmpsize(end) = '';
   msg = sprintf('[%s %s]',tmpsize,class(this.userdata));
else
   msg = 'empty';
end
disp(sprintf('\tuser data: %s',msg));

end