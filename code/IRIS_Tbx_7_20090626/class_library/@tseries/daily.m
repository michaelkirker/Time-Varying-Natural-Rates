function daily(this)
% DAILY  Display daily time series.

if datfreq(this.start) ~= 0
   error('Function DAILY can be used only on series with indeterminate frequency.');
end

% =======================================================================================
%! Function body.

% Display header.
space_();
tmpsize = size(this.data);
disp(sprintf('\ttseries object: %g-by-%g',tmpsize));
space_();

% Re-arrange data into a 2D matrix.
this.data = this.data(:,:);

% Display data, one month per row
[x,rowstart] = calendar_(this);
output = ' ';
blanks(1:size(this.data,2)-1) = {' '};
for i = 1 : length(rowstart)
   output = strvcat(output,datestr(rowstart(i),'    mmm-YYYY:'),blanks{:});
end
output = strjust(output,'right');
divider = ' ';
divider = divider(ones([size(output,1),1]));
output = [output,divider(:,[1,1])];
for i = 1 : 31
   tmp = strjust(strvcat(sprintf('[%g]',i),num2str(x(:,i))),'right');
   output = [output,tmp];
   if i < 31
      output = [output,divider(:,[1,1,1,1])];
   end
end
disp(output);

% Display comment.
disp(this.comment);

[startyear,startmonth,startday] = datevec(this.start);

end
% End of primary function.

% =======================================================================================
%! Subfunction space_().

function space_()
   if strcmp(get(0,'FormatSpacing'),'loose')
      disp(' ');
   end
end
% End of subfunction space_().

% =======================================================================================
%! Subfunction calendar_().

function [x,rowstart] = calendar_(this)

   if isnan(this.start) || isempty(this.data)
      x = [];
      rowstart = NaN;
      return
   end
   
   [nper,ncol] = size(this.data);
   [startyear,startmonth,startday] = datevec(this.start);
   [endyear,endmonth,endday] = datevec(this.start + nper - 1);
   data = this.data;
   
   % Pad missing observations at the beginning of the first month
   % and at the end of the last month with NaNs.
   tmp = eomday(endyear,endmonth);
   data = [nan([startday-1,ncol]);data;nan([tmp-endday,ncol])];
   
   % Start-date and end-date of the calendar matrixt.
   startdate = datenum(startyear,startmonth,1);
   enddate = datenum(endyear,endmonth,tmp);
   
   year = startyear : endyear;
   nyear = length(year);
   year = year(ones([1,12]),:);
   year = year(:);
   
   month = 1 : 12;
   month = transpose(month(ones([1,nyear]),:));
   month = month(:);
   
   year(1:startmonth-1) = [];
   month(1:startmonth-1) = [];
   year(end-(12-endmonth)+1:end) = [];
   month(end-(12-endmonth)+1:end) = [];
   nper = length(month);
   
   lastday = eomday(year,month);
   x = [];
   for t = 1 : nper
      tmp = nan([ncol,31]);
      tmp(:,1:lastday(t)) = transpose(data(1:lastday(t),:));
      x = [x;tmp];
      data(1:lastday(t),:) = [];
   end
   
   rowstart = datenum(year,month,1);
   
end
% End of subfunction calendar_().