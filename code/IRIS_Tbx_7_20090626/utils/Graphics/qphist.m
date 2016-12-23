function h = qphist(range,x,xlegend,dlegend,varargin)
%
% <a href="matlab: edit utils/graphics/qpdefault">UTILS/GRAPHICS/QPDEFAULT</a>  Called from within qplot.
%
% The IRIS Toolbox 2008/02/27. Copyright 2007-2008 Jaromir Benes. <a href="http://www.iris-toolbox.com">www.iris-toolbox.com</a>
%

% ###########################################################################################################
%% function body

if ~any(cellfun(@istseries,x))
  return
end

x = [x{:}];
h = hist(x(range));
if any(~cellfun(@isempty,xlegend))
  legend(xlegend{:},'Location','Best');
end
grid('on');

end
% end of primary function
