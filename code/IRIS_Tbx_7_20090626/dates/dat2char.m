function x = dat2char(dat,varargin)
% DAT2CHAR  Convert series date number(s) to character array.
%
% Syntax:
%   c = dat2char(dat,...)
% Output arguments:
%   c [ char ] Character array with text representation of serial date number(s).
% Required input arguments:
%   dat [ numeric ] <a href="dates.html">IRIS serial date number(s).</a>
% <a href="options.html">Options:</a>
%   'dateformat' [ char | 'YYYYFP' ] Requested date format.
%   'freqletters' [ char | 'YZQBM' ] Letters to represent individual frequencies (annual,semi-annual,quarterly,bimontly,monthly).

% The IRIS Toolbox 2008/10/03.
% Copyright (c) 2007-2008 Jaromir Benes.

%********************************************************************
%! Function body.

datstr = dat2str(dat,varargin{1:end});
x = char(datstr);

end
% End of primary function.