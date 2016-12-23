function [flag,index] = chklog_(m,alt)
%
% MODEL/PRIVATE/CHKLOG_  Check steady state of log variables for non-positive values.
%
% The IRIS Toolbox 2008/02/20. Copyright 2007-2008 Jaromir Benes. <a href="http://www.iris-toolbox.com">www.iris-toolbox.com</a>
%

% ###########################################################################################################
%% function body

realsmall = getrealsmall();

if nargin < 2 || (isnumeric(alt) && any(isinf(alt)))
  alt = 1 : size(m.assign,3);
end

index = find(m.log);
index = index(any(m.assign(1,index,alt) <= realsmall,3));
flag = isempty(index);
if ~flag
  warning_(34,m.name(index));
end

end

% end of primary function
% ###########################################################################################################