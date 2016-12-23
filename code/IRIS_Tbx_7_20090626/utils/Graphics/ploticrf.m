function [fg,ax] = ploticrf(m,icsel,varsel,time,plotrange)
% 
% The IRIS Toolbox 2007/11/05. Copyright 2007 Jaromir Benes. <a href="http://www.iris-toolbox.com">www.iris-toolbox.com</a>

%!

if nargin < 5
   plotrange = Inf;
end

%! function body --------------------------------------------------------------------------------------------

try
   % Try to import Time Domain package directory.
   import('time_domain.*');
end

% convert char list to cell str
if ischar(icsel)
   icsel = charlist2cellstr(icsel);
end

if ischar(varsel)
   [varsel,varcomm] = charlist2cellstr(varsel);
else
   varcomm = cell(size(varsel));
end
c = get(m,'comments');
for i = 1 : length(varsel)
   if isempty(varcomm{i})
      if isempty(c.(varsel{i}))
         varcomm{i} = varsel{i};
      else
         varcomm{i} = c.(varsel{i});
      end
   end
end

% Call Time Domain package.
% Compute ICRF.
[s,iclist,range] = icrf(m,time,'delog',false);

if length(plotrange) == 1 && isinf(plotrange)
   plotrange = range;
end

% remove log(...) or @log(...) from IC names
iclist = regexprep(iclist,'@?log\((.*?)\)','$1');
icsel = regexprep(icsel,'@?log\((.*?)\)','$1');

icindex = findnames(iclist,icsel);
aux = isnan(icindex);
icsel(aux) = [];
icindex(aux) = [];

fg = [];
ax = {};

for i = icindex
   fg(end+1) = figure();
   ax{end+1} = [];
   x = [];
   for j = 1 : length(varsel)
      x = [x,s.(varsel{j})(plotrange,i,:)];
   end
   x = transpose(x);
   if ~islinear(m)
      x = 100*x;
   end
   for j = 1 : size(x,2);
      subplot(1,size(x,2),j);
      barh(x(:,j));
      if j == 1
         set(gca,'yticklabel',varcomm);
      else
         set(gca,'yticklabel',{});
      end
      grid('on');
      ax{end}(end+1) = gca();
   end
end

end
% end of primary function ----------------------------------------------------------------------------------