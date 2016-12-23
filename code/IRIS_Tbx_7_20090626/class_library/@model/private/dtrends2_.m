function [const,ttrend,W] = dtrends_(eqtn,x,torigin,range)
%
% The IRIS Toolbox 2007/05/03. Copyright 2007 Jaromir Benes. <a href="www.iris-toolbox.com">www.iris-toolbox.com</a>
% _______________________________________________________________________________

% ###########################################################################################################
%% function body

ny = length(eqtn);
const = zeros([ny,1]);
ttrend = zeros([ny,1]);
t = 1;
const = vec(cellfun(@(fcn) fcn(x,t,0),eqtn));
ttrend = vec(cellfun(@(fcn) fcn(x,t,1),eqtn)) - const;

if isempty(range) || nargout < 3
  return
end

W = zeros([ny,length(range)]);
ttrend = range2ttrend_(range,torigin);
offset = sum(m.eqtntype <= 2);
for i = 1 : ny
  W(i,:) = eqtn{i}(x,1,ttrend);
end

end

% end of primary function
% ###########################################################################################################
