function warning(code,fname,list,varargin)

if ~iswarning('irisparser') || ~iswarning('model')
   return
end

fname = strrep(fname,'\','/');
intro = sprintf('Parsing file [%s]. ',fname);

switch code
   case 1
      msg = [intro,...
         'Cannot evaluate this !if expression: "%s". FALSE used instead.'];
end

if nargin == 1
   list = {};
end

printmsg('irisparser','warning',msg,list,code);

end