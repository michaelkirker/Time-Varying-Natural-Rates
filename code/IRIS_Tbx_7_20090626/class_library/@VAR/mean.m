function ymean = mean(w,ialt)
%
% <a href="matlab: edit VAR/mean">MEAN</a>  Unconditional mean of VAR.
%
% Syntax:
%   ymean = mean(w)
% Input arguments:
%   ymean [ numeric ] Mean of VAR process.
% Required input arguments:
%   w [ VAR ] VAR model.

% The IRIS Toolbox 2008/09/19.
% Copyright (c) 2007-2008 Jaromir Benes.

% ===========================================================================================================
%! function body 

[ny,p,nalt] = size(w);
if nargin > 1
   nalt = 1;
end

if p == 0
   if nargin > 1
      ymean = w.K(:,ialt);
   else
      ymean = w.K;
   end
   return
end

realsmall = getrealsmall();
ymean = Inf([ny,0]);
if nargin > 1
   do_();
else
   for ialt = 1 : nalt
      do_();
   end
end

% ===========================================================================================================
%! nested function do_()

function do_()
   try
      import('time_domain.*');
   end
   [T,R,k,Z,H,d,U] = sspace(w,ialt);
   nunit = sum(abs(abs(w.eigval(1,:,ialt)) - 1) <= realsmall);
   tmpmean = sum(var2poly(T(nunit+1:end,nunit+1:end)),3) \ k(nunit+1:end,1);
   index = ~isdiffuse(w.eigval(1,:,ialt),U(:,:));
   index(ny+1:end) = [];
   ymean(index,end+1) = U(index,nunit+1:end)*tmpmean;   
end
% end of nested function do_()

end
% end of primary function