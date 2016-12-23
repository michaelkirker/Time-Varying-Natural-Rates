function x = grabmodelcode(x,isfname)
%
% The IRIS Toolbox 2008/01/16. Copyright 2007-2008 Jaromir Benes. <a href="http://www.iris-toolbox.com">www.iris-toolbox.com</a>

%! 

if nargin < 2
   isfname = true;
end

% ===========================================================================================================
%! function body

starttag = '<!--SOURCE BEGIN';
endtag = 'SOURCE END-->';

if isfname
  x = file2char(x);
end

start = strfind(x,starttag);
finish = strfind(x,endtag);

if ~isempty(start) && ~isempty(finish)
   x = x(start(1)+length(starttag):finish(end)-1);
end

x = strtrim(x);

end
% end of primary function