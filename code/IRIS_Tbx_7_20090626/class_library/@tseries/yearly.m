function yearly(this)
% YEARLY  Display tseries with one full year per row.

% The IRIS Toolbox 2009/04/23.
% Copyright 2007-2009 Jaromir Benes.

%********************************************************************
%! Function body.

if any(datfreq(this.start) == [0,1])
   disp(this);
else
   % Include pre-sample and post-sample periods to complete full years.
   freq = datfreq(this.start);
   startyear = dat2ypf(this.start);
   nper = size(this.data,1);
   endyear = dat2ypf(this.start+nper-1);
   this.start = datcode(startyear,1,freq);
   this.data = rangedata(this,[this.start,datcode(endyear,freq,freq)]);   
   % Call |disp| with yearly disp2d implementation.
   disp(this,'',@disp2dyearly_);
end

end
% End of primary function.

%********************************************************************
%! Subfunction disp2dyearly_().

function [dates,data] = disp2dyearly_(start,data)
   [nper,nx] = size(data);
   freq = datfreq(start);
   nyear = nper / freq;
   data = reshape(data,[freq,nyear,nx]);
   data = permute(data,[3,1,2]);
   tmpdata = data;
   data = [];
   dates = '';
   tab = sprintf('\t');
   for i = 1 : nyear
      linestart = start + (i-1)*freq;
      lineend = linestart + freq-1;
      dates = strvcat(dates,...
         [tab,strjust(dat2char(linestart)),'-',strjust(dat2char(lineend)),': ']);
      if nx > 1
         dates = strvcat(dates,tab(ones([1,nx-1]),:));
      end
      data = [data;tmpdata(:,:,i)];
   end
end
% End of subfunction disp2dyearly_().