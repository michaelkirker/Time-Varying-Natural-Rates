function [m,npath] = updatemodel_(m,p,pindex,options)
% UPDATEMODEL_  Change parameter(s) and take care of sstate, solve, and refresh.

% The IRIS Toolbox 2009/05/07.
% Copyright 2007-2009 Jaromir Benes.

%********************************************************************
%! Function body.

persistent failed;

if nargin == 1
   m = failed;
end

assign0 = m.assign;
m.assign(1,pindex) = p;
if options.refresh && ~isempty(m.refresh)
   m = refresh(m);
end

% If only std devs have been changed, return immediately.
stdindex = false(size(m.name));
stdindex(length(m.name)-sum(m.nametype==3)+1:end) = true;
chngindex = m.assign ~= assign0;
if ~any(chngindex(~stdindex))
   npath = 1;
   return
end

if m.linear
   % Linear models.
   if options.solve
      [m,npath] = solve(m,'refresh',options.refresh);
   else
      npath = 1;
   end
   if islogical(options.sstate) && options.sstate
      m = sstate(m,'refresh',options.refresh);
   end
else
   % Non-linear models.
   if isa(options.sstate,'function_handle') && ~isempty(options.sstate)
      P = cell2struct(num2cell(m.assign),m.name,2);
      P = options.sstate(P);
      m = assign(m,P);
      if options.refresh && ~isempty(m.refresh)
         m = refresh(m);
      end
   end
   if options.solve
      [m,npath] = solve(m,'refresh',options.refresh);
   else
      npath = 1;
   end
end

end
% End of primary function.