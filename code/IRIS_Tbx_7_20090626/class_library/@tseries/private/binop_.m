function [output,varargout] = binop_(fn,a,b,varargin)
%
% TSERIES/PRIVATE/BINOP_  Implementation of binary time series operators and functions.
%
% The IRIS Toolbox 2007/10/23. Copyright 2007 Jaromir Benes. <a href="http://www.iris-toolbox.com">www.iris-toolbox.com</a>
%

% ###########################################################################################################
%% function body

if istseries(a) && istseries(b)
  [a.data,adim,anper] = reshape_(a.data);
  [b.data,bdim,bnper] = reshape_(b.data);
  if all(adim == 1) && ~all(bdim == 1) % first tseries scalar; second tseries non-scalar
    a.data = a.data(:,ones([1,prod(bdim)]));
  elseif ~all(adim == 1) && all(bdim == 1) % first tseries non-scalar; second tseries scalar
    b.data = b.data(:,ones([1,prod(adim)]));
  end
  range = union_(a.start,anper,b.start,bnper);
  output = a;
  [output.data,varargout{1:nargout-1}] = fn(getdata_(a,range),getdata_(b,range),varargin{:});
  si2 = size(output.data,2);
  % resulting time series must match the size of one of the input series
  if si2 == prod(adim)
    output.data = reshape_(output.data,adim);
    output.comment = cell([1,adim]);
  elseif si2 == prod(bdim)
    output.data = reshape_(output.data,bdim);
    output.comment = cell([1,bdim]);
  else
    error('The size of the resulting time series must match the size of one of the input time series.');
  end
  output.start = range(1);
  output.comment(:) = {''};
else
  if istseries(a)
    output = a;
    a = a.data;
  else
    output = b;
    b = b.data;
  end
  [x,varargout{1:nargout-1}] = fn(a,b,varargin{:});
  sizex = size(x);
  sizeoutput = size(output.data);
  if sizex(1) == sizeoutput(1)
    output.data = x;
    if length(sizex) ~= length(sizeoutput) || any(sizex(2:end) ~= sizeoutput(2:end)) 
      output.comment = cell([1,sizex(2:end)]);
      output.comment(:) = {''};
    end
  else
    output = x;
  end
end

if istseries(output)
  output = cut_(output);
end

end
%% end of primary function