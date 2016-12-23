function x = aggregate_(x,range,fromfreq,tofreq,options)
% AGGREGATE_  Convert high frequency to low frequence.

% The IRIS Toolbox 2009/04/07.
% Copyright (c) 2007-2009 Jaromir Benes.

switch char(options.method)
case 'first'
   options.method = @first;
case 'last'
   options.method = @last;
end

%********************************************************************
%! Function body.

if isnan(x.start) && isempty(x.data)
   return
end
if datfreq(x.start) ~= fromfreq
  error('Input argument must be a %s time series.',cellref({'annual','semi-annual','quarterly','bimonthly','monthly'},fromfreq == [1,2,4,6,12]));
end
if isempty(range)
   x = empty(x);
   return
end
if ~any(isinf(range))
   x = resize(x,range);
end

fromdate = cellref({@yy,@zz,@qq,@bb,@mm},fromfreq == [1,2,4,6,12]);
todate = cellref({@yy,@zz,@qq,@bb,@mm},tofreq == [1,2,4,6,12]);

startyear = dat2ypf(get(x,'start'));
endyear = dat2ypf(get(x,'end'));

fromdata = getdata_(x,fromdate(startyear,1):fromdate(endyear,fromfreq));
fromdatasize = size(fromdata);
nper = fromdatasize(1);
fromdata = fromdata(:,:);
nfromdata = size(fromdata,2);
factor = fromfreq/tofreq;
todata = nan([nper/factor,nfromdata]);
for i = 1 : size(fromdata,2)
   todata(:,i) = options.method(reshape(fromdata(:,i),[factor,nper/factor]));
end
todata = reshape(todata,[nper/factor,fromdatasize(2:end)]);

x.start = todate(startyear,1);
x.data = todata;
x = cut_(x);

end
% End of primary function.

%********************************************************************
%! Subfunction first().

function x = first(x)
   x = x(1,:);
end
% End of subfunction first().

%********************************************************************
%! Subfunction last().

function x = last(x)
   x = x(end,:);
end
% End of subfunction last().
