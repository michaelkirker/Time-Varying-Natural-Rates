function [frq,filter] = fdfilter(nfrq,fstring)
%
% FREQ-DOMAIN/FDFILTER  Frequency-domain filter.
%
% The IRIS Toolbox 2007/05/03. Copyright 2007 Jaromir Benes. <a href="www.iris-toolbox.com">www.iris-toolbox.com</a>

%! 

% ===========================================================================================================
%! function body

width = pi/nfrq;
frq = width/2 : width : pi;
freq = frq;
% replace matrix operators with element-by-element ones
fstring = regexprep(fstring,'(?<!\.)([\*\^/])','.$1');
% evaluate frequency response function of filter
l = exp(-1i*frq);
per = 2*pi./frq;
filter = eval(strrep(lower(fstring),'@',''));
if length(filter) == 1
  filter = ones([1,nfrq])*filter;
end
% convert to double
if ~isnumeric(filter)
  filter = +filter;
end

end
% end of primary function