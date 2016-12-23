function code = sprintf(this,varargin)
% <a href="matlab: edit VAR/sprintf">SPRINTF</a>  Write formatted VAR model code to string.
%
% Syntax:
%   s = sprintf(this,...)
% Required input arguments:
%   s [ char ] VAR model code.
%   this [ VAR ] VAR model.
% <a href="options.html">Optional input arguments:</a>
%   'decimal' [ numeric | <a href="default.html">empty</a> ] Precision (decimal places).
%   'declare' [ true | <a href="default.html">false</a> ]  Add declaration blocks for VAR variables, residuals, and equations.
%   'enames' [ cellstr | char | <a href="default.html">{'e1','e2',...}</a> ] Names of VAR residuals.
%   'format' [ char | <a href="default.html">'%+.16e'</a> ] Numeric format for parameter values.
%   'ynames' [ cellstr | char | <a href="default.html">{'y1','y2',...}</a> ] Names of VAR variables.
%   'tolerance' [ numeric | <a href="default.html">getrealsmall()</a> ] Ignore VAR parameters smaller than tolerance in absolute value.

% The IRIS Toolbox 2009/04/17.
% Copyright 2007-2009 Jaromir Benes.

default = {...
  'constant',true,...
  'decimal',[],...
  'declare',false,...
  'enames',{},...
  'format','%+.16e',...
  'ynames',{},...
  'tolerance',getrealsmall(),...
};
options = passopt(default,varargin{:});

if isempty(strfind(options.format,'%+'))
  error('Format string must contain %+.');
end

if ~isempty(options.decimal)
  options.format = ['%+.',sprintf('%g',options.decimal),'e'];
end

%********************************************************************
%! Function body.

[ny,p,nalt] = size(this);
if nalt > 1
  % cannot apply to multiple parameterisations
  error_(19,'SPRINTF or FPRINTF');
end

% variable names
if isempty(options.ynames)
  for i = 1 : ny
    options.ynames{end+1} = sprintf('y%g{t}',i);
  end
else
 for i = 1 : ny
    if isempty(strfind(options.ynames{i},'{t}'))
      options.ynames{i} = sprintf('%s{t}',options.ynames{i});
    end
  end
end
if isempty(options.enames)
  for i = 1 : ny
    options.enames{end+1} = sprintf('e%g',i);
  end
end

% time subscripts
options.ynames = strrep(options.ynames,'{t}','{%+g}');
for i = 1 : ny
  for j = 0 : p
    ynames{i}{1+j} = sprintf(options.ynames{i},-j);
  end
  ynames{i}{1} = strrep(ynames{i}{1},'{-0}','');
end
enames = options.enames;

% retrieve system matrices
A = get(this,'A');
if isempty(this.B)
  B = eye(ny);
else
  B = this.B;
end
if options.constant
   K = this.K;
else
   K = zeros([ny,1]);
end

% write equations
for eq = 1 : ny
  equation{eq} = [ynames{eq}{1},' = '];
  if abs(K(eq)) > options.tolerance
    equation{eq} = [equation{eq},' ',sprintf(options.format,K(eq))];
  end
  for t = 1 : p
    for y = 1 : ny
      if abs(A(eq,y,1+t)) > options.tolerance
        equation{eq} = [equation{eq},' ',sprintf(options.format,-A(eq,y,1+t)),'*',ynames{y}{1+t}];
      end
    end
  end
  for e = 1 : ny
    if abs(B(eq,e)) > options.tolerance
      equation{eq} = [equation{eq},' ',sprintf(options.format,B(eq,e)),'*',enames{e}];
    end
  end
end
code = sprintf('%s;\n',equation{:});

% declare variables if requested
if options.declare
  options.ynames = regexprep(options.ynames,'\{.*\}','');
  decl = sprintf('@variables:transition%s\n@variables:residual%s\n@equations:transition\n',sprintf(' %s',options.ynames{:}),sprintf(' %s',options.enames{:}));
  code = [decl,code];
end

end
% End of primary function.