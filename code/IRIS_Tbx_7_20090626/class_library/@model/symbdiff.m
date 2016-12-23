function m = symbdiff(m,varargin)
% SYMBDIFF  Evaluate symbolic derivatives for model equations. Called from within MODEL/MODEL.

% The IRIS Toolbox 2009/04/15.
% Copyright (c) 2007-2009 Jaromir Benes.

default = {...
  'simplify',Inf,...
};
options = passopt(default,varargin{:});

%********************************************************************
%! Function body.

% Symbolic math toolbox not available.
if ~issymbolic()
   warning_(37);
   return
end

% Symbolic derivatives of full equations and dtrends equations.
% No derivatives computed for dynamic links.
% Anonymous functions for symbolic derivatives of full equations and dtrends equations.
invalid = [];
m.deqtnF = cell([1,length(m.eqtn)]);
m.deqtnF(1:end) = {{}};
for eq = find(m.eqtntype <= 3)
   eqtn = func2str(m.eqtnF{eq});
   eqtn = strrep(eqtn,'@(x,t)','');
   eqtn = strrep(eqtn,'@(x,t,ttrend)','');
   eqtn = strrep(eqtn,'.*','*');
   eqtn = strrep(eqtn,'./','/');
   eqtn = strrep(eqtn,'.^','^');
   eqtn = strrep(eqtn,'+-','-'); % Symbolic Tbx does not like +-
   eqtn = strrep(eqtn,'-+','-'); % Symbolic Tbx does not like -+
   eqtn = strrep(eqtn,'++','+'); % Symbolic Tbx does not like ++
   eqtn = strrep(eqtn,'--','+'); % Symbolic Tbx does not like --
   if m.eqtntype(eq) <= 2
      % Measurement or transition equations.
      % Differentiate equations w.r.t. variables.
      % [tmocc,nmocc] = find(permute(m.occur(eq,m.nametype <= 3,:),[3,2,1]));
      [tmocc,nmocc] = findoccur_(m,eq,'<=',3);
   elseif m.eqtntype(eq) == 3
      % Deterministic trends.
      % Differentiate dtrends w.r.t. parameters.
      % [tmocc,nmocc] = find(permute(m.occur(eq,m.nametype == 4,m.tzero),[3,2,1]));
      [tmocc,nmocc] = findoccur_(m,eq,'==',4,m.tzero);
      nmocc = nmocc + sum(m.nametype <= 3);
      tmocc(:) = m.tzero;
   end
   nocc = length(nmocc);
   m.deqtnF{eq} = cell([1,nocc]);
   eqtn = regexprep(eqtn,'x\(:,(\d+),t\+(\d+)\)','x$1p$2');
   eqtn = regexprep(eqtn,'x\(:,(\d+),t-(\d+)\)','x$1m$2');
   for i = 1 : nocc
      if tmocc(i) >= m.tzero
         % Time index >= 0: replace x(1,23,t+0) with x23p0.
         unknown = sprintf('x%gp%g',nmocc(i),round(tmocc(i)-m.tzero));
      else
         % Time index < 0: replace x(1,23,t-1) with x23m1.
         unknown = sprintf('x%gm%g',nmocc(i),round(m.tzero-tmocc(i)));
      end
      try
         deqtn = diff(eqtn,unknown);
         if m.log(nmocc(i))
            deqtn = deqtn * sym(unknown);
         end
         if length(char(deqtn)) > options.simplify
            deqtn = char(simple(horner(simple(deqtn))));
         else
            deqtn = char(deqtn);
         end
         % If the symbolic expression contains "diff(...)" or "[1]"
         % (depending on the version) it means that Symbolic Tbx does
         % not know the analytical derivates of some function(s)
         % occuring in the equation.
         if ~isempty(regexp(deqtn,'\<diff\>\(','once')) || ~isempty(strfind(deqtn,'['))
            % Throw an error to move to the catch block.
            error('Symbolic derivative cannot be evaluated.');
         end
         deqtn = regexprep(deqtn,'x(\d+)p(\d+)','x(1,$1,t+$2)');
         deqtn = regexprep(deqtn,'x(\d+)m(\d+)','x(1,$1,t-$2)');
         if m.eqtntype(eq) <= 2
            m.deqtnF{eq}{i} = eval(['@(x,t) ',deqtn]);
         else
            m.deqtnF{eq}{i} = eval(['@(x,t,ttrend) ',deqtn]);
         end
      catch
         m.deqtnF{eq}{i} = [];
         invalid(end+1) = eq;
      end
   end
end

if ~isempty(invalid)
   warning_(52,m.eqtn(unique(invalid)));
end

end
% End of primary function.