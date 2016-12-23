function out = dpdistrib(dpack,fcn)
%
% DPDISTRIB  Get characteristics of data distribution in datapack.
%
% Syntax:
%   out = dpdistrib(dpack,fcn)
% Required input arguments:
%   out cell; dpack cell; fcn function_handle
%
% The IRIS Toolbox 2007/05/03. Copyright 2007 Jaromir Benes. <a href="www.iris-toolbox.com">www.iris-toolbox.com</a>

% function body ---------------------------------------------------------------------------------------------

nalt = size(dpack{2},3);
if nalt == 1
  % number of alternatives returned by fcn
  out = dpack;
  n = size(fcn(0),3);
  for i = 1 : 3, out{i} = out{i}(:,:,ones([1,n])); end
  return
end

out = {[],[],[],dpack{4},dpack{5}};
ny = size(dpack{1},1);
nx = size(dpack{2},1);
ne = size(dpack{3},1);
nper = length(dpack{4});
% transition variables
out{2} = fcn(dpack{2}(:,1,:));
out{2}(:,2:nper,:) = NaN;
out{1} = nan([ny,nper,size(out{2},3)],class(dpack{1}));
out{3} = nan([ne,nper,size(out{2},3)],class(dpack{3}));
for t = 2 : nper, out{2}(:,t,:) = fcn(dpack{2}(:,t,:)); end
% measurement and residual variables
for t = 1 : nper
  if ~isempty(dpack{1}), out{1}(:,t,:) = fcn(dpack{1}(:,t,:)); end
  if ~isempty(dpack{3}), out{3}(:,t,:) = fcn(dpack{3}(:,t,:)); end
end

end % of primary function -----------------------------------------------------------------------------------