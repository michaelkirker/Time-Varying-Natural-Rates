function varargout = x12(x,range,varargin)
% To get help for this IRIS function
% * type <a href="matlab: idoc filter.x12">idoc filter.x12</a>, or
% * open <a href="matlab: helpbrowser">Matlab Product Help</a> and go the The IRIS Toolbox at the bottom of the Contents pane,

% The IRIS Toolbox 2009/04/19.
% Copyright 2007-2009 Jaromir Benes.

default = {
   'arima',0,@(x) islogical(x) || isnumeric(x),...
   'delete',true,@islogical,...
   'display',false,@islogical,...
   'mode','auto',@(x) (isnumeric(x) && any(x == -1 : 3)) || any(strcmp(x,{'add','a','mult','m','auto','sign','pseudoadd','p','logadd','l'})),...
   'output','d11',@(x) ischar(x) || iscellstr(x),...
   'tdays',false,@islogical,...
};
options = passvalopt(default,varargin{:});

if strcmp(options.mode,'sign')
   options.mode = 'auto';
end

if nargin > 1 && ~isnumeric(range)
   error('Incorrect type of input argument(s).');
end

if nargin < 2
   range = Inf;
else
   range = setrange(range);
end

replace = {...
   'seasonal','d10',...
   'seasadj','d11',...
   'trend','d12',...
   'irregular','d13',...
};
for i = 1 : 2 : length(replace)
   options.output = strrep(options.output,replace{i},replace{i+1});
end

%********************************************************************
%! Function body.

try
   import('x12.*');
end

[x.data,dim] = reshape_(x.data);
[data,range] = getdata_(x,range);

output = regexp(options.output,'[a-zA-Z]\d\d','match');
noutput = length(output);

[varargout{1:noutput},varargout{noutput+(1:2)}] = x12(data,range(1),varargin{:});

for i = 1 : noutput
   varargout{i} = tseries(range,reshape_(varargout{i},dim));
end

end
% End of primary function.