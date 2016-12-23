function me = meta(m,mse)
%
% <a href="matlab: edit model/meta">META</a>  Model-specific meta data.

% The IRIS Toolbox 2008/09/01.
% Copyright 2007 Jaromir Benes.

if nargin < 2
   mse = false;
end

% ===========================================================================================================
%! function body

me.name = m.name;
me.nametype = m.nametype;
me.namelabel = m.namelabel;
me.log = m.log;
me.id = m.solutionid;
me.precision = m.precision;

[ny,nx,nf,nb,ne,np,nalt] = size_(m);
tmpid = printid_(m);

me.yvector = tmpid(1:ny);
me.xvector = tmpid(ny+(1:nx));
me.evector = tmpid(ny+nx+(1:ne));
me.U = m.solution{7};
me.mse = mse;
me.icondix = m.icondix;

% solution not available
[flag,index] = isnan(m,'solution');
if flag
   warning_(44,sprintf(' #%g',find(index)));
end

end
% end of primary function