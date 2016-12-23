function varargout = get(p,varargin)
%
% GET  Get attributes of simulation plan.
%
% [<value>] = get(p,<attrib>)
% Required input arguments:
%   value depends on attrib, p plan, attrib cellstr|char
% Attributes:
%   'endogenized' returns struct
%   'exogenized' returns struct
%   'datapoints' returns double
%   'range' returns double
%
% The IRIS Toolbox 2007/05/03. Copyright 2007 Jaromir Benes. <a href="www.iris-toolbox.com">www.iris-toolbox.com</a>

if nargin-1 ~= nargout && ~(nargin-1 == 1 && nargout == 0), error('Incorrect number of input or output arguments.'); end
if ~iscellstr(varargin), error('Incorrect type of input argument(s).'); end

% function body ---------------------------------------------------------------------------------------------

varargout = {};
unrecognized = {};

for i = 1 : nargin-1

  attribute = strtrim(lower(varargin{i}));
  switch attribute

  case {'range','simulationrange'}
    x = p.range;

  case {'exogenized','exogenised','anchor','exog'}
    x = p.exogenized;

  case {'endogenized','endogenised','free','endog'}
    x = p.endogenized;

  case {'ndpoints','ndatapoints'}
    nexog = 0;
    list = fieldnames(p.exogenized);
    for i = 1 : length(list)
      if istseries(p.exogenized.(list{i})), nexog = nexog + sum(p.exogenized.(list{i}) == true); end
    end
    nendog = 0;
    list = fieldnames(p.endogenized);
    for i = 1 : length(list)
      if istseries(p.endogenized.(list{i})), nendog = nendog + sum(p.endogenized.(list{i}) == true); end
    end
    x = [nexog,nendog];

  otherwise
    unrecognized{end+1} = varargin{i};
    x = [];

  end % of switch

  varargout{end+1} = x;

end % of for

if ~isempty(unrecognized), error('Unrecognised option: ''%s''.\n',unrecognized{:}); end

end % of primary function -----------------------------------------------------------------------------------