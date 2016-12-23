function x = dat2grid(x,where)

if nargin < 2
   where = 'c';
end

freq = datfreq(x);
if freq > 0
   switch where(1)
   % Centre within period.
   case 'c' 
      x = dat2dec(x);
      x = x + 1./(2*freq);
   % Start of period.
   case 's'
      x = dat2dec(x);
   case 'e'
   % End of period.
      x = dat2dec(x+1);
   end
end

end