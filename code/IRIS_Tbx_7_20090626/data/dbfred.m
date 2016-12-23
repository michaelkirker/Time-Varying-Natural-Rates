function d = dbfred(fileName,sheetName,varargin)

default = {...
   'dateformat',irisget('dateformat'),@ischar,...
};
options = passvalopt(default,varargin{:});

% =======================================================================================
%! Function body.

% Read raw excel file into cell array.
[ans,ans,sheet] = xlsread(fileName,sheetName);

% Extract years and months from date column.
dateCol = sheet(2:end,1);
dateCol = sprintf('%s|',dateCol{:});
tmp = regexp(dateCol,'(?<day>\d+)/(?<month>\d+)/(?<year>\d+)|','names');
month = str2num(['[',sprintf('%s,',tmp.month),']']);
year = str2num(['[',sprintf('%s,',tmp.year),']']);

% Determine periodicity of time series.
if all(month == 1 | month == 4 | month == 7 | month == 10)
   freq = 4;
   per = (month+2)/3;
elseif all(month == 1)
   freq = 1;
   per = month;
else
   freq = 12;
   per = month;
end

% Create IRIS serial date numbers.
dates = datcode(year,per,freq);

% Process series in columns one by one.
d = struct();
sheet(1,:) = strtrim(sheet(1,:));
for i = 2 : size(sheet,2)
   if isempty(sheet{1,i})
      continue
   end
   name = sheet{1,i};
   try
      data = cell2mat(sheet(2:end,i));
      d.(name) = tseries(dates,data);
   catch
      warning('Cannot convert column "%s" into a time series.',name);
   end
end

end
% End of primary function.