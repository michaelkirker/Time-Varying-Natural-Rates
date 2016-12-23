function flag = isVariableEditor_(x,s)
% ISVARIABLEEDITOR_  Return TRUE if this is guessed as a call from Variable Editor 2008b or higher.

% The IRIS Toolbox 2009/04/14.
% Copyright (c) 2007-2009 Jaromir Benes.

%********************************************************************
%! Function body.

if nargin > 0
   flag = datfreq(x.start) > 0 && strcmp(s(1).type,'()') ...
      && length(s.subs) == 2 && isnumeric(s.subs{1}) ...
      && all(s.subs{1} == round(s.subs{1})) && all(s.subs{2} == round(s.subs{2}));
   if flag
      return
   end
end

stack = dbstack('-completenames');
stack = [stack.file];
flag = ...
   sscanf(version(),'%f',1) > 7.7 ...
   && length(stack) > 2 ...
   && ~isempty(regexp(stack,'toolbox.matlab.codetools','once')) ...
   && isempty(regexp(stack,'toolbox.matlab.codetools.publish','once'));

end
% End of primary function.