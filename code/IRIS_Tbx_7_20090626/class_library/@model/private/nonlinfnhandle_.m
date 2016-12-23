function [eqtnN,xi,ei] = nonlinfnhandle_(m,eqtnlabel)

if issparse(m.occur)
   occur = reshape(full(m.occur),[size(m.occur,1),length(m.name),size(m.occur,2)/length(m.name)]);
end

if ischar(eqtnlabel)
   eqtnlabel = charlist2cellstr(eqtnlabel);
end

tmplabel = m.eqtnlabel;
tmplabel(m.eqtntype ~= 2) = {''};
eqtni = findnames(tmplabel,eqtnlabel);
index = isnan(eqtni); 
if any(index)
   multierror('The following equation label cannot be matched: "%s".',eqtnlabel(index));
end

n = length(eqtni);
xi = [];
ei = [];
eqtnN = {};
fnreplace = @replace_;
invalid = {};
for i = eqtni
   eqtnF = char(m.eqtnF{i});
   tokens = regexp(eqtnF,...
      '^@\(x,t\)\(x\(:,(\d+),t\+0\)\)-\((.*?)\)$',...
      'tokens','once');
   realid = str2double(tokens{1});
   tmpxi = find(m.solutionid{2} == realid);
   if isempty(tmpxi)
      xi(end+1) = NaN;
   else
      xi(end+1) = tmpxi;
   end
   tmpeqtnN = tokens{2};
   if ~isempty(tmpeqtnN)
      tmpeqtnN = regexprep(tmpeqtnN,...
         'x\(:,(\d+),t(.\d+)\)',...
         '${fnreplace($1,$2)}');
      try
      if m.log(realid)
         eqtnN{end+1} = eval(['@(x,e,p,t) log(',tmpeqtnN,')']);
      else
         eqtnN{end+1} = eval(['@(x,e,p,t) ',tmpeqtnN]);
      end
      catch Error
         invalid{end+1} = m.eqtn{i};
         invalid{end+1} = Error.message;
         eqtnN{end+1} = [];
         continue
      end
   else
      eqtnN{end+1} = '';
   end
   % Select the shock that has been declared last.
   tmpei = find(occur(i,m.nametype == 3,m.tzero),1,'last');
   if isempty(tmpei)
      ei(end+1) = NaN;
   else
      ei(end+1) = tmpei;
   end
end

if ~isempty(invalid)
   error('\nError evaluating this equation: %s\nMatlab says: %s',invalid{:});
end

tmpindex = isnan(xi);
if any(tmpindex)
   tmpindex = find(tmpindex);
   multierror('The LHS of this equation is invalid: %s.\n',m.eqtn(eqtni(tmpindex)),'iris:model');
end

tmpindex = isnan(ei);
if any(tmpindex)
   tmpindex = find(tmpindex);
   multierror('This equation has no shock: %s.',m.eqtn(eqtni(tmpindex)),'iris:model');
end


   function out = replace_(n,shift)
      n = str2double(n);
      shift = str2double(shift);
      if m.nametype(n) == 2
         % Transition variables.
         index = find(m.solutionid{2} == n+1i*shift);
         if ~isempty(index)
            time = 't';
         else
            index = find(m.solutionid{2} == n+1i*(shift+1));
            time = 't-1';
         end
         if m.log(n)
            out = sprintf('exp(x(%g,%s))',index,time);
         else
            out = sprintf('x(%g,%s)',index,time);
         end         
      elseif m.nametype(n) == 3
         % Shocks.
         index = n - sum(m.nametype < 3); 
         out = sprintf('e(%g,t)',index);
      else
         % Parameters.
         index = n - sum(m.nametype < 4);
         out = sprintf('p(%g)',index);
      end
   end

end
% End of primary function.