function [m,system] = system_(m,deriv,eqselect,ialt)
% SYSTEM_  Line up system matrices.

% The IRIS Toolbox 2009/06/12.
% Copyright 2007-2009 Jaromir Benes.

%********************************************************************
%! Function body.

nm = sum(m.eqtntype == 1);
nt = sum(m.eqtntype == 2);
mindex = find(eqselect(1:nm));
tindex = find(eqselect(nm+1:end));

ny = length(m.systemid{1});
nx = length(m.systemid{2});
ne = length(m.systemid{3});
nf = sum(double(imag(m.systemid{2}) >= 0));
nb = nx - nf;

system = m.system0;

% A1 y + B1 xb+ + E1 e + K1 = 0

system.K{1}(mindex) = deriv.c(mindex);
system.K{2}(tindex) = deriv.c(nm+tindex);

system.A{1}(mindex,m.metasystem.y) = deriv.f(mindex,m.metaderiv.y);
system.B{1}(mindex,m.metasystem.pplus) = deriv.f(mindex,m.metaderiv.pplus);
system.E{1}(mindex,m.metasystem.e) = deriv.f(mindex,m.metaderiv.e);

% A2 [xf+;xb+] + B2 [xf;xb] + E2 e + K2 = 0

system.A{2}(tindex,m.metasystem.uplus) = deriv.f(nm+tindex,m.metaderiv.uplus);
system.A{2}(tindex,nf+m.metasystem.pplus) = deriv.f(nm+tindex,m.metaderiv.pplus);
system.B{2}(tindex,m.metasystem.u) = deriv.f(nm+tindex,m.metaderiv.u);
system.B{2}(tindex,nf+m.metasystem.p) = deriv.f(nm+tindex,m.metaderiv.p);
system.E{2}(tindex,m.metasystem.e) = deriv.f(nm+tindex,m.metaderiv.e);

system.A{2}(nt+1:nx,:) = m.systemident.xplus;
system.B{2}(nt+1:nx,:) = m.systemident.x;

if ialt == 1
   for i = 1 : 2
      m.system0.A{i}(:) = system.A{i}(:);
      m.system0.B{i}(:) = system.B{i}(:);
      m.system0.E{i}(:) = system.E{i}(:);
      m.system0.K{i}(:) = system.K{i}(:);
   end
end

end
% End of primary function.