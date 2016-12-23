function display(this)
%  DISPLAY  Display container.

% The IRIS Toolbox 2009/04/01.
% Copyright 2007-2009 Jaromir Benes.

%********************************************************************
%! Function body.

isloose = strcmp(get(0,'FormatSpacing'),'loose');
disp([inputname(1),' =']);
loose_();
disp(sprintf('\tcontainer object: 1-by-1'));
loose_();
list = repository_('NAME');
disp(list);

   function loose_()
      if isloose
          disp(' ');
      end
   end   

end
% End of primary function.