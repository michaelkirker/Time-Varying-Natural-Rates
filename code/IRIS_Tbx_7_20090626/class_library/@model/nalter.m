function m = nalter(m,n)
% <a href="matlab: edit model/nalter">NALTER</a>  Query, increase or decrease number of alternative parameterizations.
%
% Syntax:
%   n = nalter(m)
%   m = nalter(m,n)
% Output arguments for syntax
%   n [ numeric ] Current number of alternative parameterisations.
%   m [ model ] Model with increased or decreased number of alternative parameterisations.
% Required input arguments:
%   m [ model ] Model.
%   n [ numeric ] Desired number of alternative parameterisations.
%
%   The number of parameterisations is changed either by copying the last one (when increasing)
%   or chopping off the last ones (when decreasing).

% The IRIS Toolbox 2009/04/01.
% Copyright 2007-2009 Jaromir Benes.

%********************************************************************
%! Function body.

nalt = length(m);

if nargin == 1
   m = nalt;
   return
end

if n > nalt
   % Expand the number of parameterisations by copying the last one:
   % Call m(end+1:n) = m(end);
   m = subsasgn(m,struct('type','()','subs',{{nalt+1:n}}),subsref(m,struct('type','()','subs',{{nalt}})));
else
   % Reduce the number of parameterisations by cutting off the last ones:
   % Call m(n+1:end) = [];
   m = subsasgn(m,struct('type','()','subs',{{n+1:nalt}}),[]);
end

end
% End of primary function.