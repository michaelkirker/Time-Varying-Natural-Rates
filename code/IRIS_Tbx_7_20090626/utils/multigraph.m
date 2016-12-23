function multigraph(varargin)
%
% multigraph(dbase,range,split,series1,title1,...)
%
% The IRIS Toolbox 2007/10/17. Copyright 2007 Jaromir Benes. <a href="http://www.iris-toolbox.com">www.iris-toolbox.com</a>
% _______________________________________________________________________________

% read database
if ischar(varargin{1})
  d = evalin('caller',varargin{1});
else
  d = varargin{1};
end
varargin(1) = [];

% read range
if ischar(varargin{1})
  range = evalin('caller',varargin{1});
else
  range = varargin{1};
end
varargin(1) = [];

% read window split
if ischar(varargin{1})
  split = evalin('caller',varargin{1});
else
  split = varargin{1};
end
varargin(1) = [];
if length(split) == 1
  split = {split,split};
else
  split = {split(1),split(2)};
end

% evaluate series
x = cell([1,ceil(length(varargin)/2)]);
[x{:}] = dbeval(d,varargin{1:2:end});

% fetch graph titles
titles = varargin(2:2:end);
titles = strrep(titles,'|',char(10));
titles = strrep(titles,'.',' ');

% plot
for i = 1 : length(x)
  subplot(split{:},i);
  plot(range,x{i});
  set(title(titles{i}),'interpreter','none');
  grid('on');
end

end