function [data,dim,nper] = reshape_(data,dim)
%
% The IRIS Toolbox 4/18/2007. Copyright 2007 Jaromir Benes.

% function body ---------------------------------------------------------------------------------------------

if nargin == 1
  dim = size(data);
  % data = reshape(data,[dim(1),prod(dim(2:end))]);
  data = data(:,:);
  nper = dim(1);
  dim = dim(2:end);
else
  data = reshape(data,[size(data,1),dim]);
end

end % of primary function -----------------------------------------------------------------------------------