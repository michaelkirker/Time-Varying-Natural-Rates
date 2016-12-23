function string = dat2str(dat,varargin)
% DAT2STR  Convert series date number(s) to cell array of string(s).
%
% Syntax:
%   s = dat2str(dat,...)
% Output arguments:
%   s [ cellstr ] Cellstr with text representation of serial date number(s).
% Required input arguments:
%   dat [ numeric ] <a href="dates.html">IRIS serial date number(s).</a>
% <a href="options.html">Options:</a>
%   'dateformat' [ char | 'YYYYFP' ] Requested date format.
%   'freqletters' [ char | 'YZQBM' ] Letters to represent individual frequencies (annual,semi-annual,quarterly,bimontly,monthly).

% The IRIS Toolbox 2008/10/03.
% Copyright (c) 2007-2008 Jaromir Benes.

config = irisget();
oldSyntax = false;

if nargin > 1 && ~strcmpi(varargin{1},'dateformat') && ~strcmpi(varargin{1},'freqletters')
   oldSyntax = true;
end

if oldSyntax == true
   options.dateformat = varargin{1};
   if nargin > 2
      options.freqletters = varargin{2};
   else
      options.freqletters = config.freqletters;
   end
else
	default = {
	  'dateformat',config.dateformat,...
	  'freqletters',config.freqletters,...
	};
	options = passopt(default,varargin{1:end});
end

%********************************************************************
%! Function body.

if isempty(options.dateformat)
   options.dateformat = config.dateformat;
end
if ~isa(options.freqletters,'char') || length(options.freqletters) ~= length(config.freqletters)
   options.freqletters = config.freqletters;
end
[year,per,freq] = dat2ypf(dat);
string = cell(size(year));
n = length(vech(year));
for k = 1 : n
   string{k} = datstr(year(k),per(k),freq(k),options.dateformat,options.freqletters);
end

end
% End of primary function.