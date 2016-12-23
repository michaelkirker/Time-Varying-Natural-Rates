function [stat,crit] = lrtest(wu,wr,level)
%
% <a href="VAR/lrtest">LRTEST</a>  Likelihood ratio test for VAR models.
%
% Syntax:
%   [stat,crit] = lrtest(w1,w2,level)
% Output arguments:
%   stat [ numeric ] Test stastic.
%   crit [ numeric ] Test critical value.
% Required input arguments:
%   wu [ VAR ] Unrestricted VAR model.
%   wr [ VAR ] Restricted VAR model.
%   level [ numeric ] Significance level (e.g. 0.05).
%
% The IRIS Toolbox 2007/07/25. Copyright 2007 Jaromir Benes. <a href="http://www.iris-toolbox.com">www.iris-toolbox.com</a>
%

if nargin < 3
  level = 0.05;
end

% ###########################################################################################################
%% function body

[nyr,pr,naltr] = size(wr);
[nyu,pu,naltu] = size(wu);
nloop = max([naltu,naltr]);

if ~(round(wu.sample(1) - wr.sample(1)) == 0 && round(wu.sample(end) - wr.sample(end)) == 0)
  error_(2);
end
nper = round(wu.sample(end) - wu.sample(1) + 1);

if wu.nhyper == wr.nhyper
  warning_(3);
end

% swap restricted and unrestricted if needed
if wu.nhyper < wr.nhyper
  [wu,wr] = deal(wr,wu);
end

stat = nan([1,nalt]);
for iloop = 1 : nloop
  if iloop <= naltr
    logdet_Omegar = log(det(wr.Omega(:,:,iloop)));
  end
  if iloop <= naltu
    logdet_Omegau = log(det(wu.Omega(:,:,iloop)));
  end
  % test statistic
  stat(iloop) = nper*(logdet_Omegar - logdet_Omegau);
end

% critical value
crit = chi2inv(1-level,wu.nhyper-wr.nhyper);

end

% end of primary function
% ###########################################################################################################