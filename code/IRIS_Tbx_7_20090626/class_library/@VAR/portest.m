function [stat,crit,range] = portest(w,data,h,level)
%
% PORTEST  Portmanteau test for autocorrelation in VAR residuals.
%
% Syntax:
%   [stat,crit,range] = portest(w,resid,h,level)
% Output arguments:
%   stat [ numeric ] Portmanteau test statistic.
%   crit [ numeric ] Critical value at desired level of significance.
%   range [ numeric ] Actually used range (IRIS serial date numbers).
% Required input arguments:
%   w [ VAR | swar ] VAR from which tested residuals were obtained.
%   data [ tseries ] VAR residuals (or VAR output data) to be tested for autocorrelation.
%   h [ numeric ] Test horizon (greater than VAR order).
%   level [ numeric ] Desired level of significance.
%
% The IRIS Toolbox 2007/08/11. Copyright 2007 Jaromir Benes. <a href="http://www.iris-toolbox.com">www.iris-toolbox.com</a>
%

if nargin < 3
  level = 0.05;
end

% ###########################################################################################################
% function body

[ny,p,nalt] = size(w);
if horizon <= p
  error_(8);
end

[e,range] = double(resid,'min');
if size(e,2) == 2*ny
  % data contain both y and e
  e(:,1:ny,:) = [];
end

% if reduced-form VAR
% orthonormalise residuals by Choleski factor of Omega
if isempty(w.B)
  for i = 1 : size(e,3)
    if i <= nalt
      P = chol(w.Omega(:,:,i));
    end
    e(:,:,i) = e(:,:,i)/P;
  end
end

% test statistic
[nper,ne,nalt] = size(e,3);
stat = zeros([1,nalt]);
for ialt = 1 : nalt
  for i = 1 : horizon
    Ci = e(:,1+i:end,ialt)*transpose(e(:,1:end-i,ialt)) / nper;
    stat(ialt) = stat(ialt) + trace(transpose(Ci)*Ci) / (nper-i);
  end
end
stat = nper^2*stat;

% critical value
if nargout > 1
  crit = chi2inv(1-level,ne^2*(horizon-p));
end

end 

% end of primary function
% ###########################################################################################################