function [flag,discrep,list] = chksstate(m,varargin)
% To get help for this IRIS function
% * type <a href="matlab: idoc model.chksstate">idoc model.chksstate</a>, or
% * open <a href="matlab: helpbrowser">Matlab Product Help</a> and browse The IRIS Toolbox documentation in the Contents pane.

% The IRIS Toolbox 2009/04/03.
% Copyright (c) 2007-2009 Jaromir Benes.

default = {
   'tolerance',getrealsmall(),@isnumericscalar,...
   'refresh',true,@islogical,...
};
options = passvalopt(default,varargin{:});

%********************************************************************
%! Function body.

% Refresh dynamic links.
if options.refresh && ~isempty(m.refresh)
   m = refresh(m);
end

% Warning if some parameters are not assigned.
[flag,list] = isnan(m,'parameters');
if flag
   warning_(2,list);
end

% warning if some steady states are not assigned
[flag,list] = isnan(m,'sstate');
if flag
   warning_(35,list);
end

% warning if some log-lin variables have non-positive steady state
chklog_(m);

t = m.tzero;
mint = 1 - t;
if issparse(m.occur)
   nt = size(m.occur,2) / length(m.name);
else
   nt = size(m.occur,3);
end
maxt = nt - t;
nalt = size(m.assign,3);

flag = false([1,nalt]);
list = cell([1,nalt]);
mval = nan([sum(m.eqtntype <= 2),nalt]);
discrep = nan([sum(m.eqtntype <= 2),2,nalt]);

% Check two consecutive periods
% to also detect incorrect growth rates.
tvec = mint : maxt+1;
for ialt = 1 : nalt
   x = trendarray_(m,1:length(m.name),tvec,true,ialt);
   x = shiftdim(x,-1);
   mval1 = vec(cellfun(@(fcn) fcn(x(:,:,1:end-1),t),m.eqtnF(m.eqtntype <= 2)));
   mval2 = vec(cellfun(@(fcn) fcn(x(:,:,2:end),t),m.eqtnF(m.eqtntype <= 2)));
   mval(:,ialt) = max(abs([mval1,mval2]),[],2);
   index = abs(mval(:,ialt)) <= options.tolerance;
   flag(ialt) = all(index == true);
   if nargout > 1
      list{ialt} = m.eqtn(~index);
   end
   discrep(:,:,ialt) = [mval1,mval2];
end

if nalt == 1 && nargout > 1
   list = list{1};
end

end
% End of primary function.