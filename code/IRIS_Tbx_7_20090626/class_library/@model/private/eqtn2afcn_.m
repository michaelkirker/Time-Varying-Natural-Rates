function m = eqtn2afcn_(m,flag)
% MODEL/PRIVATE/EQTN2FCNH_  Convert equations to anonymous functions.

% The IRIS Toolbox 2009/04/09.
% Copyright 2007-2009 Jaromir Benes.

%********************************************************************
%! Function body.

% Anonymous functions for full Y and X equations.
for i = find(m.eqtntype <= 2)
   if isempty(m.eqtnF{i})
      m.eqtnF{i} = @(x,t) 0;
   else
      m.eqtnF{i} = eval(['@(x,t) ',m.eqtnF{i}]);
   end
end

% Anonymous functions for full DTrends equations.
% treated separately because require ttrend as an extra input argument
for i = find(m.eqtntype == 3)
   if isempty(m.eqtnF{i})
      m.eqtnF{i} = @(x,t,ttrend) 0*ttrend;
   else
      m.eqtnF{i} = eval(['@(x,t,ttrend) ',m.eqtnF{i}]);
   end
end

% Anonymous functions for dynamic link equations.
for i = find(m.eqtntype == 4)
   if isempty(m.eqtnF{i})
      m.eqtnF{i} = [];
   else
      m.eqtnF{i} = eval(['@(x,t) ',m.eqtnF{i}]);
   end
end

end 
% End of primary function.