function varargout = x12(x,startdate,varargin)
% X12/X12  Called from within tseries/x12.

% The IRIS Toolbox 2009/04/19.
% Copyright 2007-2009 Jaromir Benes.

if ~isnumeric(x) && ~isnumeric(freq)
   error('Incorrect type of input argument(s).');
end

default = {
   'arima',0, @(x) islogical(x) || isnumeric(x),...
   'delete',true,@islogical,...
   'display',false,@islogical,...
   'mode','auto',@(x) (isnumeric(x) && any(x == -1 : 3)) || any(strcmp(x,{'add','a','mult','m','auto','sign','pseudoadd','p','logadd','l'})),...
   'output','d11',@(x) ischar(x) || iscellstr(x),...
   'tdays',false,@islogical,...
};
options = passvalopt(default,varargin{:});

if islogical(options.arima)
   if options.arima
      options.arima = 8;
   else
      options.arima = 0;
   end
end

switch lower(options.mode)
case {0,'mult','m'}
   options.mode = 'mult';
case {1,'add','a'}
   options.mode = 'add';
case {2,'pseudoadd','p'}
   options.mode = 'pseudoadd';
case {3,'logadd','l'}
   options.mode = 'logadd';
otherwise
   options.mode = 'auto';
end

if iscellstr(options.output)
   options.output = sprintf('%s ',options.output{:});
end
options.output = regexprep(options.output,'\s+',',');

%********************************************************************
%! Function body.

nx = size(x,2);

outputfile = {};
errorfile = {};

output = options.output;
if ischar(options.output)
   output = charlist2cellstr(options.output);
end
noutput = length(output);
[varargout{1:noutput}] = deal(nan(size(x)));
% output file(s)
varargout{noutput+1}(1:nx) = {''};
% error file(s)
varargout{noutput+2}(1:nx) = {''};

freq = datfreq(startdate);
if freq ~= 4 & freq ~= 12
   warning_(1);
   return
end

thisdir = fileparts(mfilename('fullpath'));

for i = 1 : nx
   sample = getsample(transpose(x(:,i)));
   data = x(sample,i);
   if length(data) < 3*freq
      warning_(2);
   elseif any(isnan(data))
      warning_(3);
   else
      offset = find(sample,1) - 1;
      aux = x12_(thisdir,data,startdate+offset,output,options);
      for j = 1 : noutput
         varargout{j}(sample,i) = aux(:,j);
      end
      % Catch output file.
      if exist('iris_x12a.out') == 2
         varargout{noutput+1}(i) = {file2char('iris_x12a.out')};
      end
      % Catch error file.
      if exist('iris_x12a.err') == 2
         varargout{noutput+2}(i) = {file2char('iris_x12a.err')};
      end
      % Delete all X12 files.
      if options.delete
         delete('iris_x12a.*');
      end
   end
end

end
% End of primary function.

%********************************************************************
%! Subfunction x12_().

function data = x12_(thisdir,data,startdate,output,options)

% Flip sign if all values are negative
% so that multiplicative mode is possible.
flipsign = false;
if all(data < 0)
   data = - data;
   flipsign = true;
end

nonpositive = any(data <= 0);
if strcmp(options.mode,'auto')
   if nonpositive
      options.mode = 'add';
   else
      options.mode = 'mult';
   end
elseif strcmp(options.mode,'mult') && nonpositive
   warning('Unable to use multiplicative mode because of non-positive numbers. Switching to additive mode.');
   options.mode = 'add';
end

specfile_(thisdir,data,startdate,options);

command = [fullfile(thisdir,'x12a.exe'),' iris_x12a'];
if ~options.display
   command = [command,' >> iris_x12a.txt'];
end
status = system(command);
if status ~= 0
   warning_(5);
   return
end

nper = length(data);
[data,flag] = getoutput_(nper,output);
if ~flag
   warning_(6);
   return
end

if flipsign
   data = -data;
end

end
% end of subfunction x12_()

%********************************************************************
%! Subfunction specfile_()

function specfile_(thisdir,data,startdate,options)

[startyear,startper,freq] = dat2ypf(startdate);

spec = file2char(fullfile(thisdir,'iris_x12a_template.spc'));

% time series spec

% data
spec = strrep(spec,'## series_data',sprintf('%.8f\r\n   ',data));
% seasonal period
spec = strrep(spec,'## series_period',sprintf('%.0f',datfreq(startdate)));
% start date
spec = strrep(spec,'## series_start',sprintf('%.0f.%.0f',startyear,startper));

% transform spec

if any(strcmp(options.mode,{'mult','pseudoadd','logadd'}))
   replace = 'log';
else
   replace = 'none';
end
spec = strrep(spec,'## transform_function',replace);

% forecast spec

spec = strrep(spec,'## forecast_maxlead',sprintf('%.0f',options.arima));
spec = strrep(spec,'## forecast_maxback',sprintf('%.0f',options.arima));

% x11regression spec

if options.tdays
   spec = strrep(spec,'## x11regression','x11regression');
end

% x11 spec
spec = strrep(spec,'## x11_mode',options.mode);
spec = strrep(spec,'## x11_output',options.output);

char2file(spec,'iris_x12a.spc');

end
% End of subfunction specfile_().

%********************************************************************
%! Subfunction getoutput_().

function [data,flag] = getoutput_(nper,output)

flag = true;
data = nan([nper,0]);
for ioutput = output
   fid = fopen(sprintf('iris_x12a.%s',ioutput{1}),'r');
   if fid > -1
      fgetl(fid); % skip first 2 lines
      fgetl(fid);
      read = fscanf(fid,'%f %f');
      fclose(fid);
   else
      read = [];
   end
   if length(read) == 2*nper
      read = transpose(reshape(read,[2,nper]));
      data(:,end+1) = read(:,2);
   else
      data(:,end+1) = NaN;
      flag = false;
   end
end

end
% End of subfunction getoutput_().