function this = dailyaggregate_(this,userrange,freq1,freq2,options)
% DAILYAGGREGATE_  Aggregate daily time series to requested frequency.

% The IRIS Toolbox InterestRates_Bloomberg..
% Copyright 2007-2009 Jaromir Benes.

if any(isinf(userrange))
   userrange = this.start + (0 : size(this.data,1)-1);
else
   userrange = userrange(1) : userrange(end);
end

%********************************************************************
%! Function body.

periodfcn = @(month) ceil(freq2*month/12);
datefcn = @(year,period) datcode(year,period,freq2);
[this.start,this.data] = convert_(this.start,this.data,userrange,periodfcn,datefcn,options);

end
% End of primary function.

%********************************************************************
%! Subfunction convert_().

function [start2,data2] = convert_(start,data,userrange,periodfcn,datefcn,options)

   range = start + (0 : size(data,1)-1);   
   if isempty(range)
      start2 = NaN;
      data2 = zeros([0,1]);
      return
   end
   
   tmpsize = size(data);
   data = data(:,:);
   
   tmp = datevec(userrange);
   useryear = tmp(:,1);
   userperiod = periodfcn(tmp(:,2));

   tmp = datevec(range);
   year = tmp(:,1);
   period = periodfcn(tmp(:,2));
   
   % Treat missing observations.
   for t = 2 : size(data,1);
      index = isnan(data(t,:));
      if any(index)
         switch options.missing
         case 'last'
            data(t,index) = data(t-1,index);
         otherwise
            data(t,index) = options.missing;
         end
      end
   end
   
   start2 = datefcn(useryear(1),userperiod(1));
   data2 = [];
   while ~isempty(useryear)
      index = year == useryear(1) & period == userperiod(1);
      x = data(index,:);
      nx = size(x,2);
      xagg = nan([1,nx]);
      for i = 1 : nx
         tmp = x(:,i);
         if options.ignorenan
            tmp = tmp(~isnan(tmp));
         end
         if isempty(tmp)
            xagg(1,i) = NaN;
         else
            xagg(1,i) = options.method(tmp);
         end
      end
      data2 = [data2;xagg];
      year(index) = [];
      period(index) = [];
      data(index,:) = [];
      index = useryear == useryear(1) & userperiod == userperiod(1);
      useryear(index) = [];
      userperiod(index) = [];
   end
   
   data2 = reshape(data2,[size(data2,1),tmpsize(2:end)]);
   
end
% End of subfunction convert_().