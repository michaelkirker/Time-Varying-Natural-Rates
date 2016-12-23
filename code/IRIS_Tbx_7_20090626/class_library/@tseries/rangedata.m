function [y,range] = rangedata(x,range)
% Fetch a continuous range of data.

%********************************************************************
%! Function body.

tmpsize = size(x.data);
if isnan(x.start) || isempty(x.data)
   y = nan([round(range(end)-range(1)+1),tmpsize(2:end)]);
   return
end

ncol = prod(tmpsize(2:end));

if isinf(range(1))
   % Range is Inf or [-Inf,...].
   startindex = 1;
else
   startindex = range(1) - x.start + 1;
   startindex = round(startindex);
end

if isinf(range(end))
   % Range is Inf or [...,Inf].
   endindex = tmpsize(1);
else
   endindex = range(end) - x.start + 1;
   endindex = round(endindex);
end

if startindex > endindex
   y = nan([0,ncol]);
elseif startindex >= 1 && endindex <= tmpsize(1)
   y = x.data(startindex:endindex,:);
elseif (startindex < 1 && endindex < 1) || (startindex > tmpsize(1) && endindex > tmpsize(1))
   y = nan([endindex-startindex+1,ncol]);
elseif startindex >= 1
   y = [x.data(startindex:end,:);nan([endindex-tmpsize(1),ncol])];
elseif endindex <= tmpsize(1)
   y = [nan([1-startindex,ncol]);x.data(1:endindex,:)];
else
   y = [nan([1-startindex,ncol]);x.data(:,:);nan([endindex-tmpsize(1),ncol])];
end

if length(tmpsize) > 2
   y = reshape(y,[size(y,1),tmpsize(2:end)]);
end

% Return actual range if requested.
if nargout > 1
   if all(isinf(range))
      range = x.start + (startindex : endindex) - 1;
   end
end

end
% End of primary function.