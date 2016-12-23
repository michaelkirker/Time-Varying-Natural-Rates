function disp(m)
% DISP  Display model object.

% The IRIS Toolbox 2008/10/21.
% Copyright (c) 2007-2008 Jaromir Benes.

%********************************************************************
%! Function body.

aux = iff(m.linear,'linear','nonlinear');
if isempty(m.assign)
   disp(sprintf('\tempty model object'));
else
   [flag,index] = isnan(m,'solution');
   disp(sprintf('\t%s model object: %g parameterisation(s)',aux,length(m)));
   if any(~index)
      disp(sprintf('\tsolution(s) available for a total of %g parameterisation(s)',sum(~index)));
      if m.optimal
         disp(sprintf('\tsolution(s) based on optimised rule(s)'));
      end
   else
      disp(sprintf('\tsolution(s) available for no parameterisation'));
   end
end
disp(m.contained);
loosespace();

end
% End of primary function.