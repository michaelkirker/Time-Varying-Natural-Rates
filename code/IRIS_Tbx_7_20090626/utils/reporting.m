function d = reporting(input,d,range,varargin)
% <a href="matlab: edit utils/reporting">REPORTING</a>  Evaluate reporting equations.
%
% Syntax:
%    d = reporting(fname,d,range,...)
% Output arguments:
%    d [ struct ] Output database.
% Required input arguments:
%    fname [ char ] Name of file with reporting equations.
%    d [ struct ] Input database.
%    range [ numeric ] Time range, i.e. <a href="dates.html">IRIS serial date numbers</a>.
% <a href="options.html">Optional input arguments:</a>
%    'dynamic' [ <a href="default.html">true</a> | false ] Evaluate equations period by period.
%    'merge' [ <a href="default.html">true</a> | false ] Merge output database with input datase.

% The IRIS Toolbox 2009/04/14.
% Copyright 2007-2009 Jaromir Benes.

default = {...
   'dynamic',true,@islogical,...
   'merge',true,@islogical,...
};
options = passvalopt(default,varargin{:});

%********************************************************************
%! Function body.

if ischar(input)
   % File name.
   p = irisparser(input,struct());
   eqtn = reporting(p);
elseif isstruct(input)
   % Reporting eqtn struct.
   eqtn = input;
else
   error('Invalid type of input argument(s).');
end

if ~isstruct(eqtn) || isempty(eqtn) || ~isfield(eqtn,'lhs') || isempty(eqtn.lhs)
   return
end

list = fieldnames(d);
for i = 1 : length(list)
   if ~istseries(d.(list{i})) && ~any(strcmp(eqtn.lhs,list{i}))
      eqtn.rhs = strrep(eqtn.rhs,sprintf('d.%s(t,:)',list{i}),sprintf('d.%s',list{i}));
   end
end

% Pre-allocate time series and assign comments.
for i = 1 : length(eqtn.lhs)
   if ~isfield(d,eqtn.lhs{i})
      d.(eqtn.lhs{i}) = tseries();
   end
   if ~isempty(eqtn.label{i})
      d.(eqtn.lhs{i}) = comment(d.(eqtn.lhs{i}),eqtn.label{i});
   end
end

if options.dynamic
   % Evaluate equations recursively period by period.
   fn = cell(size(eqtn.rhs));
   for i = 1 : length(eqtn.rhs)
      fn{i} = eval(sprintf('@(d,t)%s',eqtn.rhs{i}));
   end
   range = vech(range);
   for t = range
      for i = 1 : length(eqtn.rhs)
         try
            x = fn{i}(d,t);
         catch
            x = NaN;
         end
         if ~isnumeric(x)
            x = eqtn.nan{i};
         else
            x(isnan(x)) = eqtn.nan{i};
         end
         tmpsize = size(d.(eqtn.lhs{i}));
         if length(tmpsize) == 2 && tmpsize(2) == 1 && length(x) > 1
            d.(eqtn.lhs{i}) = scalar2nd(d.(eqtn.lhs{i}),size(x));
         end
         d.(eqtn.lhs{i})(t,:) = x;
      end
   end
else
   % Evaluate equations for all periods at once.
   for i = 1 : length(eqtn.rhs)
      eqtn.rhs = strrep(eqtn.rhs,'(t,:)','{range,:}');
      try
         x = eval(eqtn.rhs{i});
      catch Error
         x = NaN;
         warning('iris:reporting',...
            'Error evaluating "%s".\nMatlab says: %s',...
            eqtn.userRHS{i},Error.message);
      end
      d.(eqtn.lhs{i}) = x;
   end
end

if ~options.merge
   d = d * eqtn.lhs;
end

end
% End of primary function.