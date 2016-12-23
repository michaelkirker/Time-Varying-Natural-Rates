function timeline(h,userrange,freq,options)

userrange = userrange(1) : userrange(end);

% Determine xLim.
if all(isinf(userrange))
   xlim = get(h,'xlim');
   % Lower limit: First period in first year.
   first = datcode(floor(xlim(1)),1,freq);
   % Upper limit: Last period in last year.
   last = datcode(floor(xlim(end)),freq,freq);
   xlim = dat2grid([first,last]);
else
   xlim = dat2grid(userrange([1,end]));
end
set(h,'xLim',xlim,'xLimMode','manual');

if isinf(options.datetick)
   % Determine step and xTick.
   % Step is number of periods.
   xtick = get(h,'xtick');
   if length(xtick) > 1
      step = round(freq*(xtick(2) - xtick(1)));
   else
      step = 1;
   end
   if step < 1
      step = 1;
   end
   if step < freq
      % Make sure freq/step is integer.
      if rem(freq,step) > 0
         step = freq / floor(freq/step);
      end
   elseif step > freq
      % Make sure step/freq is integer.
      if rem(step,freq) > 0
         step = freq * floor(step/freq);
      end
   end
   nstep = round(freq/step*(xlim(2) - xlim(1)));
   xtick = xlim(1) + step/freq*(0 : nstep);
else
   xtick = dat2grid(options.datetick);
end
set(h,'xTick',xtick,'xTickMode','manual');

% Set xTickLabel.
xticklabel = dat2str(grid2dat(xtick,freq),'dateformat',options.dateformat);
set(h,'xTickLabel',xticklabel,'xTickLabelMode','manual');

end