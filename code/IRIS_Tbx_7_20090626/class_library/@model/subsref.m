function varargout = subsref(m,s)
% <a href="matlab: edit model/subsref">SUBSREF</a>  Subscripted reference to model objects.
%
% Syntax:
%   m(index)        (1)
%   m.name          (2)
%   m.name(index)   (3)
% Required input arguments:
%   m [ model ] Model.
% Required input arguments for syntax (1) and (3):
%   index [ logical | numeric | empty] Index of requested parameterisations.
% Required input arguments for syntax (2) and (3):
%   name [ char ] Name of requested parameter or variable.
%
% Nota bene:
%   Syntax (1) produces a model object with the requested subset of parameterisations.
%   Syntax (2) produces a vector of values currently assigned to the requested parameters, or a vector
%   of steady-state values for the requested variable.
%   Syntax (3) produces the same as Syntax (2) for the requested subset of parameterisations.

% The IRIS Toolbox 2009/04/28.
% Copyright (c) 2007-2008 Jaromir Benes.

%********************************************************************
%! Function body.

% chksubsref returns
% a(numeric)
% a.name(numeric)
% where numeric is positive integers
nalt = size(m.assign,3);
s = chksubsref_(s,nalt);

% m(index) or m{index}

if any(strcmp(s(1).type,{'()','{}'}))

   index = s(1).subs{1};
   if any(index > nalt)
      error('Index exceeds number of parameterisations.');
   end
   refer_();
   varargout{1} = m;

% m.name or m.name(index)

elseif strcmp(s(1).type,'.')

   index = strcmp(s(1).subs,m.name);
   if ~any(index)
      error('Unrecognised variable or parameter name: "%s".',s(1).subs);
   end
   varargout{1} = vech(m.assign(1,index,:));
   
   % m.name(index)
   
   if length(s) > 1
      varargout{1} = subsref(varargout{1},s(2:end));
   end

end

% End of function body.

%********************************************************************
%! Nested function refer_().

function refer_()
   m.assign = m.assign(1,:,index);
   m.eigval = m.eigval(1,:,index);
   m.optimal = m.optimal(1,index);
   for i = 1 : length(m.solution)
      m.solution{i} = m.solution{i}(:,:,index);
   end
   for i = 1 : length(m.expand)
      m.expand{i} = m.expand{i}(:,:,index);
   end
end
% End of nested function refer_().

end
% End of primary function.