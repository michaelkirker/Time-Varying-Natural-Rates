function dbase = dbunoper(dbase0,fn,varargin)

if ~isstruct(dbase0) || ~ischar(mask) || ~ischar(expr)
  error('Incorrect type of input argument(s).');
end  

default = {
  'namefilter',inf,...
  'classfilter',inf,...
  'append',true,...
};
options = passopt(default,varargin{:});

%% -----{function DBUNOPER body}-----

if options.append == true
  dbase = dbase0;
else
  dbase = struct();
end

invalid = cell([0,1]);
if isa(nameFilter,'char')
  for field = vech(fieldnames(dbase0))
    string = rexpn(field{1},nameFilter,0);
    if strcmp(field{1},string) && (any(isinf(classFilter)) || isa(dbase0.(field{1}),classFilter))
      try
        dbase.(field{1}) = feval(fn,dbase0.(field{1}),varargin{:});
      catch
        dbase.(field{1}) = NaN;
        invalid{end+1} = field{1};
      end
    end
  end
else
  if isnumeric(nameFilter) && all(isinf(nameFilter))
    nameFilter = fieldnames(dbase0);
  end
  for field = vech(nameFilter)
    if isfield(dbase0,field{1}) && (any(isinf(classFilter)) || isa(dbase0.(field{1}),classFilter))
      try
        dbase.(field{1}) = feval(fn,dbase0.(field{1}),varargin{:});
      catch
        dbase.(field{1}) = NaN;
        invalid{end+1} = field{1};
      end
    end
  end
end

if ~isempty(invalid)
  disp('Warning: Unable to perform the operation with the following field(s) (NaN assigned instead):');
  disp(printcell(invalid));
end

return