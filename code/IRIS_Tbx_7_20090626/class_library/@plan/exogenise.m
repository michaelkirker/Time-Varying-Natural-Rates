function p = exogenise(p,name,range)
% <a href="matlab: edit plan/exogenise">EXOGENISE</a>  Exogenise variables (and/or previously endogenised residuals) for simulation.
%
% Syntax:
%   p = exogenise(p,name,range)
% Output arguments:
%   p [ plan ] Simulation plan with newly exogenised data points.
% Required input arguments:
%   p [ plan ] Simulation plan.
%   name [ cellstr | char ] List of variables (and/or previously endogenised residuals) to be exogenised.
%   range [ numeric ] Dates or time range, i.e. <a href="dates.html">IRIS serial date numbers</a>. 

% The IRIS Toolbox 2009/05/20.
% Copyright (c) 2007-2009 Jaromir Benes.

if (~iscellstr(name) && ~ischar(name)) || ~isnumeric(range)
   error('Incorrect type of input argument(s).');
end

if ischar(name)
   name = charlist2cellstr(name);
end

%********************************************************************
%! Function body.

if ~isnan(p.range)
   flag = false;
   before = round(range - p.range(1)) < 0;
   after = round(range - p.range(end)) > 0;
   tmp = [range(before),range(after)];
   if ~isempty(tmp)
      warning_(5,format_(name,tmp));
   end
end

if ~isempty(range) && ~isempty(name)
   modelname = [p.meta.name(real(p.meta.id{1})),p.meta.name(real(p.meta.id{2}))];
   [p.exogenized,p.endogenized,unable] = datapoints_(modelname,p.exogenized,p.endogenized,name,range);
   if ~isempty(unable)
      warning_(1,format_(unable,range));
   end
end

end
% End of primary function.

%********************************************************************
%! Subfunction format_().
% Format dates for warning messages.
function x = format_(name,range)
   tmp = dat2str(range);
   tmp = sprintf(' %s',tmp{:});
   x = {};
   for i = 1 : length(name)
      x(end+1) = {sprintf('''%s'' in period(s)%s',name{i},tmp)};
   end
end
% End of subfunction format_().