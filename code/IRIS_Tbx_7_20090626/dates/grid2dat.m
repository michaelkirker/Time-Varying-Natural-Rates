function x = dat2grid(x,freq)

if freq > 0
   x = x - 1./(2*freq);
   x = dec2dat(x,freq);
end

end