function list = toaremos(d,bank,varargin)
%
% <a href="matlab: edit utils/interface/toaremos">TOAREMOS</a>  Export time series to AREMOS databank.
%
% Syntax:
%   list = toaremos(d,bank,...)
% Output arguments:
%   list [ cellstr ] List of actually exported datase entries.
% Required input arguments:
%   d [ struct ] <a href="databases.html">Database</a> to be exported.
%   bank [ char | cellstr ] AREMOS databank name.
% <a href="options.html">Optional input arguments:</a>
%   'inf' [ numeric | <a href="default.html">realmax()</a> ] Numerical value for Infs.
%   'nan' [ numeric | <a href="default.html">1e15</a> ] Numerical value for missing observations.
%   'saveas' [ char | <a href="default.html">'fromaremos'</a> ] TSD and CMD file names (w/o extension).
%
% The IRIS Toolbox 2007/06/27. Copyright 2007 Jaromir Benes. <a href="http://www.iris-toolbox.com">www.iris-toolbox.com</a>
%

default = {...
  'inf',realmax(),...
  'nan',1e15,...
  'saveas','toaremos',...
};
options = passopt(default,varargin{:});

if ischar(bank)
  bank = {bank};
end

% ###########################################################################################################
%% function body

[fpath,ftitle,fext] = fileparts(options.saveas);
fpath = 'c:/warem52/export';
fname = fullfile(fpath,ftitle);
fnamecmd = sprintf('%s.cmd',fname);
fnametsd = sprintf('%s.tsd',fname);

command = '';
newline = sprintf('\r\n');

if exist(fpath) ~= 7
  mkdir(fpath);
end

fid = fopen(fnamecmd,'w+');
if fid == -1
  error('Unable to open %s for writing.',upper(fnamecmd));
end
fclose(fid);

fid = fopen(fnametsd,'w+');
if fid == -1
  error('Unable to open %s for writing.',upper(fnametsd));
end
fclose(fid);

[list,range] = dbase2tsd(d,fnametsd,'inf',options.inf,'nan',options.nan);
if range(1) < 1901 || range(2) > 2099
  error('AREMOS period cannot start before 1901 or end after 2099.');
end

% open databank
bank = sprintf('%s,',bank{:});
bank(end) = '';
if ~isempty(bank)
  command = [command,newline,sprintf('open <primary> %s;',bank)];  
end

% set period
if ~isempty(range) && ~any(isinf(range))
  command = [command,newline,sprintf('set per %g %g;',range)];
end

% list of variables names
if ~isempty(list)
  command = [command,newline,sprintf('import <format=tsd> from %s;',fnametsd)];
end

% close all databank
command = [command,newline,'close *;'];

% save CMD file
char2file(command,fnamecmd);

% call barem32 and execute CMD file
system(sprintf('c:/warem52/barem32.exe %s',fnamecmd));

end
% end of primary function