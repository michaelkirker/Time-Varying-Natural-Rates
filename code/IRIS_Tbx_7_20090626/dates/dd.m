function x = dd(year,month,day)

if nargin < 2
   month = 1;
end

if nargin < 3
   day = 1;
elseif strcmpi(day,'end')
   day = eomday(year,month);
end

year = year(:);
month = month(:);
day = day(:);

nyear = length(year);
nmonth = length(month);
nday = length(day);

n = max([nyear,nmonth,nday]);
if n > 1
   if nyear == 1
      year = year(ones([n,1]));
   end
   if nmonth == 1
      month = month(ones([n,1]));
   end
   if nday == 1
      day = day(ones([n,1]));
   end
end

x = datenum([year,month,day]);

end