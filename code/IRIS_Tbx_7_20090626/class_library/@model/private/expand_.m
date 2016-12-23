function [R,Jk] = expand_(R,k,Xa,Xf,Ru,J,Jk)
%
% MODEL/PRIVATE/EXPAND_  Expand model solution forward up to t+k.
%
% The IRIS Toolbox 2008/02/10. Copyright 2007-2008 Jaromir Benes. <a href="http://www.iris-toolbox.com">www.iris-toolbox.com</a>

% ###########################################################################################################
%% function body

ne = size(Ru,2);
if ne == 0
   return
end
k0 = size(R,2)/ne - 1; % expansion up to t+k0 available
if k0 >= k % expansion already available
   return
end

% pre-allocate NaNs
R(:,end+(1:ne*(k-k0))) = NaN;

% expansion matrices not available
if any(any(isnan(Xa)))
   return
end

% compute expansion
for i = k0+1 : k
   Ra = -Xa*Jk*Ru; % Jk stores J^(k-1)
   Jk = Jk*J;
   Rf = Xf*Jk*Ru;
   R(:,i*ne+(1:ne)) = [Rf;Ra];
end

end%function
% end of primary function
