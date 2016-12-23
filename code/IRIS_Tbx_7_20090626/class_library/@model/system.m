function [A,B,C,D,F,G,H,J,list,nf] = system(m,alt)
%
% To get help for this IRIS function
% * type <a href="matlab: idoc model.system">idoc model.system</a>, or
% * open <a href="matlab: helpbrowser">Matlab Product Help</a> and go the The IRIS Toolbox at the bottom of the Contents pane,
%
% The IRIS Toolbox. Copyright 2007-2008 Jaromir Benes. <a href="http://www.iris-toolbox.com">www.iris-toolbox.com</a>

% A E[xf;xb] + B [xf(-1);xb(-1)] + C + D e = 0
% F y + G xb + H + J e = 0

% xf unpredetermined transition variables
% xb predetermined transition variables
% y measurement variables
% e residuals

nalt = size(m.assign,3);
if nargin < 2
  alt = 1 : nalt;
elseif islogical(alt)
  alt = find(alt);
end

for ialt = transpose(alt(:))
  eqselect = eqselect_(m,ialt);
  eqselect(m.eqtntype == 3) = false;
  [m,deriv] = deriv_(m,eqselect,ialt);
  [m,sys] = system_(m,deriv,eqselect,ialt);
  F(:,:,ialt) = full(sys.A{1});
  G(:,:,ialt) = full(sys.B{1});
  H(:,1,ialt) = full(sys.K{1});
  J(:,:,ialt) = full(sys.E{1});
  A(:,:,ialt) = full(sys.A{2});
  B(:,:,ialt) = full(sys.B{2});
  C(:,1,ialt) = full(sys.K{2});
  D(:,:,ialt) = full(sys.E{2});
end

list{1} = printid(m.name(real(m.systemid{1})),imag(m.systemid{1}),m.log(real(m.systemid{1})));
list{2} = printid(m.name(real(m.systemid{2})),imag(m.systemid{2}) + 1,m.log(real(m.systemid{2})));
list{3} = printid(m.name(real(m.systemid{3})),imag(m.systemid{3}),m.log(real(m.systemid{3})));
nf = sum(imag(m.systemid{2}) >= 0);

end