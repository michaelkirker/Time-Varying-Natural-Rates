function this = tseries(varargin)
% To get help for this IRIS function
% * type <a href="matlab: idoc tseries.tseries">idoc tseries.tseries</a>, or
% * open <a href="matlab: helpbrowser">Matlab Product Help</a> and browse The IRIS Toolbox documentation in the Contents pane.

% The IRIS Toolbox 2008/10/21.
% Copyright (c) 2007-2008 Jaromir Benes.

userdata = contained();

% empty constructor
if nargin == 0
  this = empty_();
  this = class(this,'tseries',contained());
  return
end

% tseries input
if nargin == 1 && istseries(varargin{1})
  this = varargin{1};
  return
end

% struct input: called from within load(), loadobj(), loadstruct(), cat()
if nargin == 1 && isstruct(varargin{1})
  this = empty_();
  list = fieldnames(this);
  for i = 1 : length(list)
    try
      this.(list{i}) = varargin{1}.(list{i});
    end
  end
  this = class(this,'tseries',contained());
  this = cut_(this);
  return
end

% dates
if isnumeric(varargin{1})
  dates = varargin{1};
else
  error('Incorrect type of input argument(s).');
end

% data
if nargin < 2
  data = nan([size(dates,1),1]);
elseif isnumeric(varargin{2}) || islogical(varargin{2}) || ischar(varargin{2}) || isa(varargin{2},'function_handle')  
  data = varargin{2};
else
  error('Incorrect type of input argument(s).');
end

% comments
if nargin < 3
  comment = '';
elseif ischar(varargin{3}) || iscellstr(varargin{3})
  comment = varargin{3};
else
  error('Incorrect type of input argument(s).');
end

% =======================================================================================
%! Function body.

this = empty_();
dates = dates(:);
dataclass = class(data);

freq = datfreq(dates);
freq(isnan(freq)) = [];
if length(freq) > 1 && any(freq(1) ~= freq(2:end))
  error('All dates must have the same frequency.');
end

if ischar(data) || isa(data,'function_handle')
  data = feval(data,[length(dates),1]);
elseif isnumeric(data) || islogical(data)
  if sum(size(data) > 1) == 1 && length(data) > 1 && length(dates) > 1
    % squeeze if scalar time series entered as other-than-columnwise vectors
    data = data(:);
  elseif length(data) == 1 && length(dates) > 1
    % expand scalar data point to match more than one dates
    data = data(ones(size(dates)));
  end
end

[this.start,this.data,dim] = init_(dates,data);

this.comment = cell([1,dim]);
this.comment(:) = {''};
if ~isempty(comment)
   if ischar(comment)
      this.comment(:) = {comment};
   else
      this.comment(:) = comment(:);
   end
end
this = class(this,'tseries',contained());
this = cut_(this);

if strcmp(dataclass,'single')
  this.data = single(this.data);
end

end
% End of primary function.

% =======================================================================================
%! Subfunction empty_().

function this = empty_() 
   this.IRIS_TSERIES = true;
   this.start = NaN;
   this.data = zeros([0,1]);
   this.comment = {''};
end 
% End of subfunction function empty_().
