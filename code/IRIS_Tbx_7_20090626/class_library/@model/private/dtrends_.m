function [const,ttrend,W] = dtrends_(m,range,alt)
% DTRENDS_   Evaluate deterministic trends.

% The IRIS Toolbox 2009/04/09.
% Copyright 2007-2009 Jaromir Benes.

if nargin < 2
   range = [];
end

if nargin < 3
   alt = Inf;
end

if isnumeric(alt) && any(isinf(alt))
   nalt = size(m.assign,3);
   alt = 1 : nalt;
elseif islogical(alt)
   alt = find(alt);
   nalt = length(alt);
else
   alt = vech(alt);
   nalt = length(alt);
end

%********************************************************************
%! Function body.

ny = sum(m.nametype == 1);

eqtn = m.eqtnF(m.eqtntype == 3);
const = zeros([ny,nalt]);
ttrend = zeros([ny,nalt]);
t = 1;
for ialt = alt
   x = m.assign(1,:,ialt);
   const(:,ialt) = vec(cellfun(@(fcn) fcn(x,t,0),eqtn));
   ttrend(:,ialt) = vec(cellfun(@(fcn) fcn(x,t,1),eqtn)) - const(:,ialt);
end

if ~isempty(range) && nargout > 2
   ttrend = range2ttrend_(range,m.torigin);
   W = zeros([ny,length(range),0]);
   offset = sum(m.eqtntype <= 2);
   for ialt = alt
      W(:,:,end+1) = 0;
      x = m.assign(1,:,ialt);
      for iy = 1 : ny
         W(iy,:,end) = m.eqtnF{offset+iy}(x,1,ttrend);
      end
   end
end

end
% End of primary function.