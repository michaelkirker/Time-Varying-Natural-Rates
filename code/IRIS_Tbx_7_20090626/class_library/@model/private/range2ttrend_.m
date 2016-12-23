function t = range2ttrend_(range,torigin)
% Linear time trend for deterministic trend equations.

% The IRIS Toolbox 2008/10/08.
% Copyright (c) 2007-2008 Jaromir Benes.

% =======================================================================================
%! Function body.

if isempty(range)
   t = range;
else
   freq = datfreq(range(1));
   if freq == 0
      t = range;
   else
      if isempty(torigin)
         torigin = 2000;
      else
         torigin = datcode(round(torigin),1,freq);
      end
      t = floor(range - torigin);
   end
end

end
% End of primary function.