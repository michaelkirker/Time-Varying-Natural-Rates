function [m,deriv] = deriv_(m,eqselect,ialt)
% DERIV_  Compute first-order expansion of equations around current steady state for parameterisations.

% The IRIS Toolbox 2009/05/07.
% Copyright (c) 2007-2009 Jaromir Benes.

%********************************************************************
%! Function body.

realsmall = getrealsmall();
deriv = m.deriv0;
assign = m.assign(1,:,ialt);
if any(eqselect)
   nt = size(m.occur,2) / length(m.name);
   nvar = sum(m.nametype <= 3);
   t = m.tzero;
   if ~isempty(m.deqtnF)
      % Symbolic derivatives available.
      numNeeded = false;
      sderiv_();
   else
      numNeeded = true;
   end
   % Numerical derivatives need to be computed.
   if numNeeded
      nderiv_();
   end
   % Normalise derivatives by largest number in non-linear models.
   if ~m.linear
      for eq = find(eqselect)
         index = deriv.f(eq,:) ~= 0;
         if any(index)
            norm = max(abs(deriv.f(eq,index)));
            deriv.f(eq,index) = deriv.f(eq,index) / norm;
         end
      end
   end   
end

if ialt == 1
   m.assign0(:) = m.assign(1,:,ialt);
   m.deriv0.c(:) = deriv.c;
   m.deriv0.f(:) = deriv.f;
end

% End of function body.





%********************************************************************
%! Nested function nderiv_().
% Numerical derivatives.
   function nderiv_() 
   
      mint = 1 - t;
      maxt = nt - t;
      tvec = mint : maxt;
   
      if m.linear
         init = zeros(size(m.assign));
         init(1,m.nametype == 4) = real(assign(m.nametype == 4));
         init = init(1,:,ones([1,nt]));
         h = ones([1,length(m.name),nt]);
      else
         init = trendarray_(m,1:length(m.name),tvec,false,ialt);
         init = shiftdim(init,-1);
         h = abs(m.epsilon)*max([init;ones([1,length(m.name),nt])],[],1);
      end
   
      plus = init + h;
      minus = init - h;
      step = plus - minus;
   
      if ~m.linear
         init(1,m.log,:) = exp(init(1,m.log,:));
         plus(1,m.log,:) = exp(plus(1,m.log,:));
         minus(1,m.log,:) = exp(minus(1,m.log,:));
      end
   
      fgrid = cell([1,3]);
      fevaluate = cell([1,3]);
   
      for eq = find(eqselect)
   
         [tmocc,nmocc] = findoccur_(m,eq,'<=',3);         

         % Find available symbolic derivatives.
         if isempty(m.deqtnF)
            symAvailableIndex = false(size(tmocc));
         else
            symAvailableIndex = ~cellfun(@isempty,m.deqtnF{eq});
         end
         if all(symAvailableIndex)
            continue,
         end
         tmocc = tmocc(~symAvailableIndex);
         nmocc = nmocc(~symAvailableIndex);
         
         n = length(nmocc); % Number of derivatives to be computed.
         
         fgrid{2} = init;
         for i = [1,3]
            fgrid{i} = init(ones([1,n]),:,:);
         end
         for i = 1 : n
            fgrid{1}(i,nmocc(i),tmocc(i)) = minus(1,nmocc(i),tmocc(i));
            fgrid{3}(i,nmocc(i),tmocc(i)) = plus(1,nmocc(i),tmocc(i));
         end
   
         for i = [1,3]
            x = fgrid{i};
            fevaluate{i} = m.eqtnF{eq}(x,t);
         end
   
         % Constant in linear models.
         if m.linear
            x = fgrid{2};
            deriv.c(eq) = m.eqtnF{eq}(x,t);
         end
   
         value = zeros([1,n]);
         for i = 1 : n
            value(i) = (fevaluate{3}(i)-fevaluate{1}(i)) / step(1,nmocc(i),tmocc(i));
         end

         % Round numbers close to integers.
         roundIndex = abs(value - round(value)) <= realsmall;
         value(roundIndex) = round(value(roundIndex));

         % Assign values to the array of derivatives.
         index = vech((tmocc-1)*nvar + nmocc);
         deriv.f(eq,index) = value;
      end
   
   end
% End of nested function nderiv_().





%********************************************************************
%! Nested function sderiv_().
% Symbolic derivatives.
   function sderiv_() 
      
      if m.linear
         x = zeros(size(m.assign));
         x(1,m.nametype == 4) = real(assign(m.nametype == 4));
         x = x(1,:,ones([1,nt]));
      else
         mint = 1 - t;
         maxt = nt - t;
         tvec = mint : maxt;
         x = trendarray_(m,1:length(m.name),tvec,true,ialt);
         x = shiftdim(x,-1);
      end
      
      for eq = find(eqselect)
         [tmocc,nmocc] = findoccur_(m,eq,'<=',3);
         % Find available symbolic derivatives (NaN instead of function handle).
         symAvailableIndex = ~cellfun(@isempty,m.deqtnF{eq});
         % Indicate that some derivatives need to be computed numerically.
         if any(~symAvailableIndex)
            numNeeded = true;
         end
         if ~any(symAvailableIndex)
            continue,
         end   
         tmocc = tmocc(symAvailableIndex);
         nmocc = nmocc(symAvailableIndex);
         n = length(nmocc); % Number of derivatives to be computed.
         % Constant in linear models.
         if m.linear
            deriv.c(eq) = m.eqtnF{eq}(x,t);
         end
         % Evaluate all derivatives of equation.
         value = cellfun(@(fcn) fcn(x,t),m.deqtnF{eq}(symAvailableIndex));
         % Assign values to the array of derivatives.
         index = vech((tmocc-1)*nvar + nmocc);
         deriv.f(eq,index) = value;
      end
      
   end  
% End of nested function sderiv_().





end
% End of primary function.