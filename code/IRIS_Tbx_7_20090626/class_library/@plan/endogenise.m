function p = endogenise(p,name,range)
% <a href="matlab: edit plan/endogenise">ENDOGENISE</a>  Endogenise residuals (and/or previously exogenised variables) for simulation.
%
% Syntax:
%   p = endogenise(p,name,range)
% Output arguments:
%   p [ plan ] Simulation plan with newly endogenised data points.
% Required input arguments:
%   p [ plan ] Simulation plan.
%   name [ cellstr | char ] List of residuals (and/or previously exogenised variables) to be endogenised.
%   range [ numeric ] Dates or time range, i.e. <a href="dates.html">IRIS serial date numbers</a>. 

% The IRIS Toolbox 2009/05/20.
% Copyright (c) 2007-2008 Jaromir Benes.

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
      warning_(6,format_(name,tmp));
   end
end

if ~isempty(range) && ~isempty(name)
   modelname = p.meta.name(real(p.meta.id{3}));
   [p.endogenized,p.exogenized,unable] = datapoints_(modelname,p.endogenized,p.exogenized,name,range);
   if ~isempty(unable)
      warning_(2,format_(unable,range));
   end
end

end
% End of primary function.

%********************************************************************
%! Subfunction format_().
% Format dates for warning message.
function x = format_(name,range) 
   tmp = dat2str(range);
   tmp = sprintf(' %s',tmp{:});
   x = {};
   for i = 1 : length(name)
      x(end+1) = {sprintf('''%s'' in period(s)%s',name{i},tmp)};
   end
end
% End of subfunction format_().