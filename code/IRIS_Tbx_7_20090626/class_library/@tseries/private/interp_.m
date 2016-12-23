function x = interp_(x,range1,freq1,freq2,options)
% Called from within tseries/convert. Convert low-frequency series to
% high-frequency series by interpolating.

% The IRIS Toolbox 2009/05/26. Copyright (c) 2007-2008 Jaromir Benes.

%******************************************************************** !
%Function body.

if isnan(x.start) && isempty(x.data)
   return
end
if datfreq(x.start) ~= freq1
  error('Input argument must be a %s time series.',cellref({'annual','semi-annual','quarterly','bimonthly','monthly'},freq1 == [1,2,4,6,12]));
end
if isempty(range1)
   x = empty(x);
   return
end
if ~any(isinf(range1))
   range = range1(1) : range1(end);
end

[xdata,range1] = getdata_(x,range1);

[startyear1,startper1] = dat2ypf(range1(1));
[endyear1,endper1] = dat2ypf(range1(end));

startyear2 = startyear1;
endyear2 = endyear1;
% Find the earliest freq2 period contained (at least partially) in freq1
% start period.
startper2 = 1 + floor((startper1-1)*freq2/freq1);
% Find the latest freq2 period contained (at least partially) in freq1 end
% period.
endper2 = ceil((endper1)*freq2/freq1);
range2 = datcode(startyear2,startper2,freq2) : datcode(endyear2,endper2,freq2);

grid1 = dat2grid(range1);
grid2 = dat2grid(range2);
data2 = interp1(grid1,x.data,grid2,options.method,'extrap');
if size(data2,1) == 1 && size(data2,2) == length(range2)
   data2 = vec(data2);
end
x.start = range2(1);
x.data = data2;
x = cut_(x);

end
% end of primary function