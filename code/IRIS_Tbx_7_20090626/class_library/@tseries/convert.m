function this = convert(this,freq2,range,varargin)
% To get help for this IRIS function
% * type <a href="matlab: idoc tseries.convert">idoc tseries.convert</a>, or
% * open <a href="matlab: helpbrowser">Matlab Product Help</a> and go the The IRIS Toolbox at the bottom of the Contents pane,

% The IRIS Toolbox 2008/09/30.
% Copyright (c) 2007-2008 Jaromir Benes.

freq1 = datfreq(this.start);
freq2 = recognisefreq(freq2);

if isempty(freq2)
   error('Cannot determine requested output frequency.');
end

if nargin < 3
   range = Inf;
end

if freq1 == freq2
   if any(isinf(range))
      return
   else
      this.data = rangedata(this,range);
      this.start = range(1);
      this = cut_(this);
      return
   end%if
elseif freq1 == 0
   % Conversion of daily series.
   default_method = @mean;
   call = @dailyaggregate_;
else
   % Conversion of Y, Z, Q, B, or M series.
   if freq1 > freq2
      % aggregate
      default_method = @mean;
      call = @aggregate_;
   else
      % interpolate
      default_method = 'cubic';
      call = @interp_;
   end
end

default = {...
   'function',[],@(x) isempty(x) || isa(x,'function_handle') || ischar(x),...
   'missing',NaN,@(x) any(strcmpi(x,{'last'})) || (isnumeric(x) && length(x) == 1),...
   'ignorenan',true,@islogical,...
   'method',default_method,@(x) isa(x,'function_handle') || ischar(x),...
};
options = passvalopt(default,varargin{:});

if ~isempty(options.function)
   options.method = options.function;
end

%********************************************************************
%! Function body.

this = call(this,range,freq1,freq2,options);
   
end
% End of primary function.