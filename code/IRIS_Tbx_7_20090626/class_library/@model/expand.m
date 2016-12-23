function m = expand(m,k)
% To get help for this IRIS function
% * type <a href="matlab: idoc model.expand">idoc model.expand</a>, or
% * open <a href="matlab: helpbrowser">Matlab Product Help</a> and go the The IRIS Toolbox at the bottom of the Contents pane,

% The IRIS Toolbox 2009/05/14.
% Copyright 2007-2009 Jaromir Benes.

%********************************************************************
%! Function body.

[ny,nx,nf,nb,ne,np,nalt] = size_(m);
if ne == 0
   return
end
R = m.solution{2};

% Expansion up to t+k0 available.
k0 = size(R,2)/ne - 1; 

% Expansion up to t+k already available.
if k0 >= k
   return 
end

m.solution{2}(:,end+(1:ne*(k-k0)),1:nalt) = NaN;
[flag,index] = isnan(m,'solution');
for ialt = find(~index)
   % m.expand{5} Jk stores J^(k-1) and needs to be updated after each expansion.
   [m.solution{2}(:,:,ialt),m.expand{5}(:,:,ialt)] = ...
      expand_(R,k,m.expand{1}(:,:,ialt),m.expand{2}(:,:,ialt),m.expand{3}(:,:,ialt),m.expand{4}(:,:,ialt),m.expand{5}(:,:,ialt));
end

% Expansion matrices not available
% because this is an optimal rule model.
[flag,index] = isnan(m,'expansion');
if flag
   warning_(45,sprintf(' #%g',find(index)));
end

end
% End of primary function.