function p = plan(m,range)
% <a href="matlab: edit plan/plan">PLAN</a>  Create a new simulation plan.
%
% Syntax:
%   p = plan(m,range)
% Output arguments:
%   p [ plan ] New (empty) simulation plan.
% Required input arguments:
%   m [ model ] Model that will be simulated.
%   range [ numeric ] Simulation time range, i.e. <a href="dates.html">IRIS serial date numbers</a>.

% The IRIS Toolbox 2009/06/24.
% Copyright 2007-2009 Jaromir Benes.

%********************************************************************
%! Function body.

p = class(empty_(),'plan');
if nargin > 0
   p.meta = meta(m,false);
   if nargin > 1
      p.range = min(range) : max(range);
   end
end

end
% End of primary function.

%********************************************************************
%% subfunction empty_()

function p = empty_() 
   p.meta = struct();
   p.range = NaN;
   p.exogenized = struct();
   p.endogenized = struct();
end
  
% End of subfunction empty_().