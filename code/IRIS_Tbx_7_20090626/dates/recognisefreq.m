function freq = recognisefreq(freq)
% RECOGNISEFREQ  Recognise date frequency in letters or numbers.

freqNum = [1,2,4,6,12];

if ischar(freq)
   if ~isempty(freq)
      freqLetter = 'yzqbm';
      freq = lower(freq(1));
      if freq == 'a'
         % Dual options for annual frequency: Y or A.
         freq = 'y';
      elseif freq == 's'
         % Dual options for semi-annual frequency: Z or S.
         freq = 'z';
      end
      freq = freqNum(freq == freqLetter);
   else
      freq = [];
   end
elseif ~any(freq == freqNum)
   freq = [];
end

end