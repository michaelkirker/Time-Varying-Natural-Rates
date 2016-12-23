function x = vertcat(varargin)
% VERTCAT  Vertical concatenation of time series.
%
% Syntax:
%   x = vertcat(x,y,...)
%   z = [x;y;...]

% The IRIS Toolbox 2009/06/09.
% Copyright 2007-2009 Jaromir Benes.

%********************************************************************
%! Function body.

if length(varargin) == 1
   x = varargin{1};
   return
end

% Check classes and frequencies.
[inputs,ixtseries] = catcheck_(varargin{:});
if any(~ixtseries)
   error('iris:tseries','Cannot concatenate tseries objects with non-tseries objects.');
end

ninput = length(inputs);
x = inputs{1};
xsize = size(x.data);
x.data = x.data(:,:);

for i = 2 : ninput
   y = inputs{i};
   ysize = size(y.data);
   y.data = y.data(:,:);
   xsize2 = size(x.data,2);
   ysize2 = size(y.data,2);
   if xsize2 ~= ysize2
      if xsize2 == 1
         x.data = x.data(:,ones([1,ysize2]));
         xsize = ysize;
         xsize2 = ysize2;
      elseif ysize2 == 1
         y.data = y.data(:,ones([1,xsize2]));
         y.comment = y.comment(1,ones([1,xsize2]));
         ysize2 = xsize2;
      else
         error('iris:tseries','Sizes of concatenated time series are not consistent.');
      end
   end
   startdate = min([x.start,y.start]);
   enddate = max([x.start+size(x.data,1)-1,y.start+size(y.data,1)-1]);
   range = startdate : enddate;
   xdata = rangedata(x,range);
   ydata = rangedata(y,range);
   index = ~isnan(ydata);
   xdata(index) = ydata(index);
   x.data = xdata;
   x.start = startdate;
end

x.data = reshape(x.data,[size(x.data,1),xsize(2:end)]);
x.comment = y.comment;
x = cut_(x);

end
% End of primary function.