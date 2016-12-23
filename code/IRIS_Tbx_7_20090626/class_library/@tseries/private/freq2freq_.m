function x = freq2freq_(x,range,fromfreq,tofreq,fn)
%
% TSERIES/PRIVATE/FREQ2FREQ_  General frequency conversion for time series.
%
% The IRIS Toolbox 2007/05/03. Copyright 2007 Jaromir Benes. <a href="www.iris-toolbox.com">www.iris-toolbox.com</a>
%

switch char(fn)
   case 'first'
      fn = @first;
   case 'last'
      fn = @last;
end

% ###########################################################################################################
%% function body

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
  todata(:,i) = fn(reshape(fromdata(:,i),[factor,nper/factor]));
end
todata = reshape(todata,[nper/factor,fromdatasize(2:end)]);

x.start = todate(startyear,1);
x.data = todata;
x = cut_(x);

end
% end of primary function

% ###########################################################################################################
%% subfunction first()

function x = first(x)
x = x(1,:);
end
% end of subfunction first()

% ###########################################################################################################
%% subfunction last()

function x = last(x)
x = x(end,:);
end
% end of subfunction last()


