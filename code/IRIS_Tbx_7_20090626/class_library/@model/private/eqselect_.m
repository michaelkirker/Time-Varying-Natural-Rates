function index = eqselect_(m,ialt,flag)
% Select equations that contain parameters that have changed since last system.

% The IRIS Toolbox 2009/02/12.
% Copyright (c) 2007-2009 Jaromir Benes.

%********************************************************************
%! Function body.

index = true(size(m.eqtn));

if nargin > 2 && ~flag
  % user forces all equations to be selected
  return
end

realsmall = getrealsmall();
assign = m.assign(1,:,ialt);

% No change in steady state.
nochange = all(ref(abs(m.assign0 - assign),m.nametype <= 2) <= realsmall);
% Derivatives exist.
isderiv = any(m.deriv0.c ~= 0) || any(any(m.deriv0.f(1:sum(m.eqtntype <= 2),:)));

if (m.linear && isderiv) || nochange
   % Changed parameters.
   tmp = find(m.nametype == 4 & assign ~= m.assign0 & (~isnan(assign) | ~isnan(m.assign0)));
   % Affected equations.
   index = vech(any(m.occur(:,(m.tzero-1)*length(m.name)+tmp),2));
end

end
% End of primary function