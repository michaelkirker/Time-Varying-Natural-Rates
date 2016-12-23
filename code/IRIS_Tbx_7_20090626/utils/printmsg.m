function printmsg(class,type,msg,list,code)
% Print error and warning messages.

% The IRIS Toolbox 2009/06/22.
% Copyright (c) 2007-2009 Jaromir Benes.

%********************************************************************\
%! Function body.

if strcmp(type,'warning') && ~iswarning(class)
   return
end

if ~iscell(list)
   list = {list};
end

ref = sprintf('<%s:%s code="%02g"/>',lower(class),lower(type),code);
id = sprintf('IRIS:%s',class);
body = sprintf(['*** ',msg,'\n'],list{:});
body = body(1:end-1);

[stack,niris] = getstack();
if strcmp(type,'warning')
   % Throw a warning with dbstack report on non-iris function calls.
   aux = warning('query','backtrace');
   warning('off','backtrace');
   msg = sprintf('<a href="">The IRIS Toolbox Warning %s.</a>\n%s',ref,body);
   disp(msg);
   dbstack(niris);
   disp(' ');  
   lastwarn(msg,id);
   warning(aux.state,'backtrace');
else
   % Throw an error with stack of non-iris function calls.
   tmp = struct();
   tmp.message = sprintf('The IRIS Toolbox Error %s.\n%s',ref,body);
   tmp.identifier = id;
   if isempty(stack)
      tmp.stack = struct('file','','name','','line',NaN);
   else
      tmp.stack = stack;
   end  
   error(tmp);
end

end
% End of primary function.

%********************************************************************
%! Subfunction getstack().

function [stack,niris] = getstack()
   stack = dbstack('-completenames');
   % Get the IRIS root directory name.
   [ans,irisfolder] = fileparts(irisget('irisroot'));
   % Exclude functions contained in the IRIS root directory.
   found = false;
   for i = 1 : length(stack)
      if isempty(strfind(stack(i).file,irisfolder))
         found = true;
         break
      end
   end
   if found
      % Subtract another 1 because this function "getstack()"
      % is counted as well.
      stack(1:i-2) = [];
      niris = i - 1;
   else
      stack = [];
      niris = i - 1;
   end   
end
% End of subfunction getstack().