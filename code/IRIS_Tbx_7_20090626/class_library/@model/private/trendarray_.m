function X = trendarray_(m,id,tvec,delog,alt)
% TRENDARRAY_  Create array with steady state paths for all variables.

% The IRIS Toolbox 2009/05/12.
% Copyright 2007-2009 Jaromir Benes.

if nargin < 5
   alt = inf;
end

%********************************************************************
%! Function body.

if islogical(alt)
   alt = find(alt);
elseif isnumeric(alt) && any(isinf(alt))
   alt = 1 : size(m.assign,3);
end

nper = length(tvec);
nid = length(id);
X = zeros([nid,nper,length(alt)]);

if nid == 0
  return
end

assign = m.assign(1,:,alt);

realid = real(id);
imagid = imag(id);

logindex = m.log(realid);
repeat = ones([1,nper]);
shift = vec(imagid);
shift = shift(:,repeat);
shift = shift + tvec(ones([1,nid]),:);

for i = 1 : length(alt)
   level = real(assign(1,realid,i));
   growth = imag(assign(1,realid,i));   
   
   % No imaginary part means
   % zero growth for log variables.
   growth(logindex & growth == 0) = 1;   
   
   level(logindex) = reallog(level(logindex));
   growth(logindex) = reallog(growth(logindex));
   level = transpose(level);
   growth = transpose(growth);
   x = level(:,repeat) + shift.*growth(:,repeat);
   if delog
      x(logindex,:) = exp(x(logindex,:));
   end
   
   X(:,:,i) = x;
end

end
% End of primary function.