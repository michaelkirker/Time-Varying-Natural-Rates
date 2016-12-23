function ctranspose(this)
% CTRANSPOSE  Display tseries one year per row.

% The IRIS Toolbox 2009/04/23.
% Copyright 2007-2009 Jaromir Benes.

%********************************************************************
%! Function body.

if ~any(datfreq(this.start) == [0,1])
   disp(this,true,true,inputname(1));
else
   disp(this,true,false,inputname(1));
end

end
% End of primary function.