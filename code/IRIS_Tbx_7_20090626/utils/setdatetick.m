function setdatetick(handle,freq,dateformat,datetick)
% Called from within tseries/private/graph_ and tseries/plotyy.

% The IRIS Toolbox 2008/09/30.
% Copyright (c) 2007-2008 Jaromir Benes.

if freq > 0 && (nargin < 3 || strcmp(dateformat,'auto') || isempty(dateformat))
   dateformat = irisget('plotdateformat');
end

if nargin < 4
   datetick = Inf;
end

% =======================================================================================
%! Function body.

for i = 1 : length(handle(:))
   xtick = get(handle(i),'xtick');
   xlim = get(handle(i),'xlim');
   if ~isnan(freq)
      if freq > 0 && any(isinf(datetick))
         multiple = max([round((xtick(2)-xtick(1)) * freq),1]);
         set(handle(i),'xtick',(xlim(1):multiple/freq:xlim(2)));
      elseif ~any(isinf(datetick))
         set(handle(i),'xtickmode','manual','xtick',dat2dec(datetick));
         set(handle(i),'xlimmode','manual','xlim',dat2dec(datetick([1,end])));
      end
      range = dec2dat(transpose(get(handle(i),'xtick')),freq);
      set(handle(i),'xticklabelmode','manual');
      if ~strcmp(dateformat,'auto')
         set(handle(i),'xticklabel',char(dat2str(range,dateformat)));
      end
      set(handle(i),'xtickmode','manual');
   else
      set(handle(i),'xtick',xlim);
      set(handle(i),'xticklabel',strvcat('NaN','NaN'));
   end
end

end
% End of primary function.