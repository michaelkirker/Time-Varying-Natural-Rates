function error(code,fname,list,varargin)

fname = strrep(fname,'\','/');
intro = sprintf('Parsing file [%s]. ',fname);

switch code
   case 0
      msg = [intro,...
         sprintf('Cannot find !%s:transition. This is not a valid model code.',...
         varargin{1})];
   case 1
      msg = [intro,...
            'This is not a valid keyword: "%s".'];
   case 2
      msg = [intro,...
         'This is not a valid variable or parameter name: "%s".'];
   case 3
      msg = [intro,...
         'This name is declared more than once: "%s".'];
   case 4
      msg = [intro,...
         'This name cannot be declared in !variables:log: "%s".'];
   case 6
      msg = [intro,...
         sprintf('Invalid model structure: %s',varargin{1})];
   case 8
      msg = [intro,...
         'Syntax error in "%s" \n\t%s'];      
   case 9
      msg = [intro,...
         'Cannot evaluate some of the time subscripts in this equation: "%s".'];
   case 38
      msg = [intro,...
         'Undeclared or mistyped name "%s" in equation "%s".'];
   case 52
      msg = [intro,...
         'Keyword <a href="matlab: idoc model_code.!allbut">!allbut</a> may appear in either all or none of <a href="matlab: idoc model_code.!variables:log">!variables:log</a> sections.'];
   case 55
      msg = [intro,...
         'Invalid deterministic trend equation: "%s".'];
   case 67
      msg = [intro,...
         'Invalid dynamic link equation: "%s"'];
   case 68
      msg = [intro,...
         sprintf('The file contains characters beyond char(%g).',varargin{1})];
         
end

if nargin == 1
   list = {};
end

printmsg('irisparser','error',msg,list,code);

end