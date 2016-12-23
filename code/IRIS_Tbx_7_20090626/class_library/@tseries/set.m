function x = set(x,varargin)
%
% SET  Set time series attributes.
%
% Syntax:
%   x = set(x,attrib1,value1,attrib2,value2,...)
% Required input arguments:
%   x [ tseries ] Time series.
%   attrib [ char ] Attribute
%   value [ anything ] Value to be assigned to attribute.
% Attributes:
%   'comment' [ char ]
%   'freq' [ numeric ]
%   'end' [ numeric ]
%   'range' [ numeric ]
%   'start' [ numeric ]
%
% The IRIS Toolbox 2007/07/19. Copyright 2007 Jaromir Benes. <a href="http://www.iris-toolbox.com">www.iris-toolbox.com</a>

if ~iscellstr(varargin(1:2:end))
  error('Incorrect type of input argument(s).');
end

% function body ---------------------------------------------------------------------------------------------

invalid = cell([1,0]);
for i = 1 : 2 : nargin-1
  if ~set_(varargin{i},varargin{i+1})
    invalid{end+1} = varargin{i};
  end
end

if ~isempty(invalid)
  warning(sprintf('Unrecognised attribute: ''%s''. ',invalid{:}));
end

% end of function body --------------------------------------------------------------------------------------

  function flag = set_(attribute,value) % nested function ---------------------------------------------------
  attribute(isspace(attribute)) = '';
  attribute = lower(attribute);
  flag = true;
  switch attribute
  case {'start','startdate','first'}
    x.start = value;
  case {'end','enddate','last'}
    x.start = value - size(x.data,1) + 1;
  case {'data'}
    x.data = value;
  case 'comment'
    x = comment(x,value);
  otherwise
    flag = false;
  end % of switch
  end % of nested function ----------------------------------------------------------------------------------

end % end of primary function -------------------------------------------------------------------------------