function disp(w)
% DISP  Display VAR object.

% The IRIS Toolbox 2009/06/24.
% Copyright 2007-2009 Jaromir Benes.

%********************************************************************
%! Function body.

[ny,p,nalt] = size(w);
if isempty(w.A)
   disp(sprintf('\tempty VAR object'));
else
   if isempty(w.B)
      type = 'reduced-form';
   else
      type = 'structural';
   end
   disp(sprintf('\t%s VAR object: %g parameterisation(s)',type,nalt));
end
disp(w.contained);
loosespace();

end
% End of primary function.