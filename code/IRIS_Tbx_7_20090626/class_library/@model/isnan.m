function [flag,list] = isnan(m,varargin)
%
% To get help for this IRIS function
% * type <a href="matlab: idoc model.isnan">idoc model.isnan</a>, or
% * open <a href="matlab: helpbrowser">Matlab Product Help</a> and go the The IRIS Toolbox at the bottom of the Contents pane,
%
% The IRIS Toolbox. Copyright 2007-2008 Jaromir Benes. <a href="http://www.iris-toolbox.com">www.iris-toolbox.com</a>

if nargin == 1
  request = 'all';
else
  request = lower(strtrim(varargin{1}));
end

% ###########################################################################################################
%% function body

switch request
case 'all'
  index = any(isnan(m.assign),3);
  if nargout > 1
    list = m.name(index);
  end
case {'p','parameters'}
  index = any(isnan(m.assign),3) & m.nametype == 4;
  if nargout > 1
    list = m.name(index);
  end
case {'sstate'}
  index = any(isnan(m.assign),3) & m.nametype <= 3;
  if nargout > 1
    list = m.name(index);
  end
case {'solution'}
  index = vech(any(any(isnan(m.solution{1}),1),2));
  if nargout > 1
    list = index;
  end
case {'expansion'}
  index = vech(any(any(isnan(m.expand{1}),1),2));
  if nargout > 1
    list = index;
  end
otherwise
  error('Incorrect input argument: %s.',varargin{1});
end
flag = any(index);

end

% end of primary function
% ###########################################################################################################