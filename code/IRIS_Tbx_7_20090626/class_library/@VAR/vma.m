function Phi = vma(w,nper)
%
% <a href="matlab: edit rvar/vma">VMA</a>  VMA representation of RVAR.
%
% Syntax:
%   Phi = vma(w,nper)
% Output arguments:
%   Phi [ numeric ] VMA matrices.
% Required input arguments:
%   w [ rvar ] RVAR model.
%   nper [ numeric ] Order up to which VMA is computed.
%
% The IRIS Toolbox 2007/10/11. Copyright 2007 Jaromir Benes. <a href="http://www.iris-toolbox.com">www.iris-toolbox.com</a>

%! 

if ~isnumeric(nper)
   error('Incorrect type of input argument(s).');
end

% ===========================================================================================================
%! function body

try
   % Try to import Time Domain package directory.
   import('time_domain.*');
end

Phi = var2vma(w.A,w.B,nper);

end
% end of primary function