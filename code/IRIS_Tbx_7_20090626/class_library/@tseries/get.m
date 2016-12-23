function varargout = get(x,varargin)
%
% <a href="tseries/get">GET</a>  Access/query attributes and properties of time series object.
%
% Syntax:
%   [value1,value2,...] = get(x,attrib1,attrib2,...)
% Required input arguments:
%   value [ anything ] Value of attribute.
%   x [ tseries ] Time series.
%   attrib [ char ] Attribute.
% Attributes:
%   'comment' returns char
%   'freq' returns numeric
%   'end' returns numeric
%   'range' returns numeric
%   'min' returns numeric
%   'start' returns numeric

% The IRIS Toolbox 2009/06/10.
% Copyright 2007-2009 Jaromir Benes.%

if nargin-1 ~= nargout && nargout > 0
  error('Invalid number of input or output arguments.');
end

if ~iscellstr(varargin(1:2:end))
  error('Incorrect type of input argument(s).');
end

%********************************************************************
%! Function body.

invalid = cell([1,0]);
for i = 1 : nargin-1
  [varargout{i},flag] = get_(varargin{i});
  if ~flag
    invalid{end+1} = varargin{i};
  end
end

if ~isempty(invalid)
  multierror('Unrecognised attribute: "%s".',invalid);
end
% End of function body.

%********************************************************************
%! Nested function get_().
   function [out,flag] = get_(attribute)
     attribute(isspace(attribute)) = '';
     attribute = lower(attribute);
     tokens = regexp(attribute,'(dat2char|dat2str)\((.*?)\)','tokens');
     if ~isempty(tokens)
       attribute = tokens{1}{2};
       transform = str2func(tokens{1}{1});
     else
       transform = @(x) x;
     end
     flag = true;
     switch attribute
     case {'range','first2last','start2end','first:last','start:end'}
       out = transform(range_(x));
     case {'min','minrange','nanrange'}
       sample = all(~isnan(x.data(:,:)),2);
       out = range_(x);
       out = transform(out(sample));
     case {'start','startdate','first'}
       out = transform(x.start);
     case {'nanstart','nanstartdate','nanfirst'}
       sample = all(~isnan(x.data(:,:)),2);
       if isempty(sample)
         out = NaN;
       else
         out = x.start + find(sample,1,'first') - 1;
       end
       out = transform(out);
     case {'end','enddate','last'}
       out = transform(x.start + size(x.data,1) - 1);
     case {'nanend','nanenddate','nanlast'}
       sample = all(~isnan(x.data(:,:)),2);
       if isempty(sample)
         out = NaN;
       else
         out = x.start + find(sample,1,'last') - 1;
       end
       out = transform(out);
     case {'freq','frequency','per','periodicity'}
       if isempty(x.start), out = NaN;
         else out = datfreq(x.start); end
     case {'data','value','values'}
       out = x.data;
     case {'comment','comments'}
       out = comment(x);
     otherwise
       flag = false;
       out = [];
     end % of switch
   end
% End of nested function get_().

end
% End of primary function.
