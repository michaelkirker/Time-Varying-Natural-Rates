function [y,w,e] = simulatemean(T,R,K,Z,H,D,U,a0,e,nper,anticipate,deviation,f)
% SIMULATEMEAN  Simulate mean in general state space.

% The IRIS Toolbox 2009/06/22.
% Copyright 2007-2009 Jaromir Benes.

%********************************************************************
%! Function body.

ny = size(Z,1);
[nx,nb] = size(T);
nf = nx - nb;
ne = size(e,1);
y = nan([ny,nper]);
w = nan([nx,nper]); % := [xf;a]
x = nan([nx,nper]); % := [xf;xb]
if anticipate
   eA = real(e);
   eU = imag(e);
else
   eA = imag(e);
   eU = real(e); 
end
lastresidA = find(any(eA ~= 0,1),1,'last');
lastresidU = find(any(eU ~= 0,1),1,'last');     
RindexA = any(abs(R(:,1:ne*lastresidA)) > 0,1);
RindexU = any(abs(R(:,1:ne)) > 0,1);
if ny > 0 || ~isempty(f)
   Hindex = any(abs(H(:,1:ne)) > 0,1);
end

% Multipliers of shocks in fast exogenised simulations.
if ~isempty(f)
   if isempty(U)
      Mx = R;
   else
      Mx = [R(1:nf,1:ne);U*R(nf+1:end,1:ne)];
   end
   My = Z*R(nf+1:end,1:ne) + H;
end

for t = 1 : nper
   if t == 1
      w(:,t) = T*a0;
   else
      w(:,t) = T*w(nf+1:end,t-1);
   end
   if ~deviation
      w(:,t) = w(:,t) + K;
   end
   if lastresidA > 0
      tmpeA = vec(eA(:,t:t+lastresidA-1));
      Eindex = vech(tmpeA ~= 0);
      tmpindex = RindexA & Eindex;
      if any(tmpindex)
         w(:,t) = w(:,t) + R(:,tmpindex)*tmpeA(tmpindex);
      end
   end
   if lastresidU > 0
      Eindex = vech(eU(:,t) ~= 0);
      tmpindex = RindexU & Eindex;
      if any(tmpindex)
         w(:,t) = w(:,t) + R(:,tmpindex)*eU(tmpindex,t);
      end
   end
   lastresidA = lastresidA - 1;
   lastresidU = lastresidU - 1;
   RindexA = RindexA(1,1:end-ne);
   if ~isempty(f)
      % Measurement equations.
      y(:,t) = Z*w(nf+1:end,t);
      y(:,t) = y(:,t) + H(:,Hindex)*(eU(Hindex,t) + eA(Hindex,t));
      if ~deviation
         y(:,t) = y(:,t) + D;
      end
   end
   % Fast exogenised simulation.
   if ~isempty(f) && any(f.anchors{3}(:,t))         
      % Convert alpha vector into xb vector.
      if isempty(U)
         x = w(:,t);
      else
         x = [w(1:nf,t);U*w(nf+1:end,t)];
      end
      % Prediction error.
      pe = [...
        f.ytune(f.anchors{1}(:,t),t)-y(f.anchors{1}(:,t),t);...
        f.xtune(f.anchors{2}(:,t),t)-x(f.anchors{2}(:,t));...
      ];
      % Back out shock additions.
      adde = [My(f.anchors{1}(:,t),f.anchors{3}(:,t));Mx(f.anchors{2}(:,t),f.anchors{3}(:,t))] \ pe;
      % Re-compute transition and measurement variables.
      y(:,t) = y(:,t) + My(:,f.anchors{3}(:,t))*adde;
      x = x + Mx(:,f.anchors{3}(:,t))*adde;
      eU(f.anchors{3}(:,t),t) = eU(f.anchors{3}(:,t),t) + adde;
      % Convert xb vector into alpha vector.
      if isempty(U)
         w(:,t) = x;
      else
         w(:,t) = [x(1:nf);U\x(nf+1:end)];
      end   
   end
end

% Mesurement variables are compute outside unless this is fast
% exogenised simulation.
if ny > 0 && isempty(f)
   y = Z*w(nf+1:end,1:nper) +...
      H(:,Hindex)*(eU(Hindex,1:nper) + eA(Hindex,1:nper));
   if ~deviation
      y = y + D(:,ones([1,nper])); 
   end
end

% Report anticipated and unanticipated residuals together as complex
% numbers.
if nargout > 2
   if anticipate
      e = eA + 1i*eU;
   else
      e = eU + 1i*eA;
   end
end

end
% End of primary function.