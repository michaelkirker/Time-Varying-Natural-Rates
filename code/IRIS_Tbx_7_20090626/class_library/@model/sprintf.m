function s = sprintf(this,varargin)
%
% To get help for this IRIS function
% * type <a href="matlab: idoc model.sprintf">idoc model.sprintf</a>, or
% * open <a href="matlab: helpbrowser">Matlab Product Help</a> and go the The IRIS Toolbox at the bottom of the Contents pane,

% The IRIS Toolbox 2008/08/31.
% Copyright (c) 2007-2008 Jaromir Benes.

default = {...
   'prefix','p.',@ischar,...
   'xsstate',true,@islogical,...
   'ysstate',true,@islogical,...
   'esstate',false,@islogical,...
   'parameters',true,@islogical,...
   'format','%.16g',@ischar,...
};
options = passvalopt(default,varargin{:});

% ===========================================================================================================
%! function body

index = false(size(this.name));
if options.ysstate
   index = index | this.nametype == 1;
end
if options.xsstate
   index = index | this.nametype == 2;
end
if options.esstate
   index = index | this.nametype == 3;
end
if options.parameters
   index = index | this.nametype == 4;
end
name = this.name(index);
assign = this.assign(1,index,:);
nalt = size(this.assign,3);

if size(this.assign,3) == 1
   format = '%s%s = %s;\n';
else
   format = '%s%s = [%s];\n';
end
s = '';
for i = 1 : length(name)
   tmp = sprintf_(options.format,assign(1,i,:));
   s = [s,sprintf(format,options.prefix,name{i},tmp)];
end

end
% end of primary function

% ===========================================================================================================
%! subfunction sprintf_()

function x = sprintf_(format,value)
   n = length(value);
   realvalue = real(value);
   imagvalue = imag(value);
   x = '';
   for i = 1 : n
      switch sign(imagvalue(i))
      case 0
         x = [x,sprintf(format,realvalue(i))];
      case 1
         x = [x,sprintf([format,'+1i*',format],realvalue(i),imagvalue(i))];
      case -1
         x = [x,sprintf([format,'-1i*',format],realvalue(i),-imagvalue(i))];
      end
      if i < n
         x = [x,', '];
      end
   end
end
% end of subfunction sprintf_()