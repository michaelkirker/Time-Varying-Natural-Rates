function d = plus(d1,d2)
%
% STRUCT/PLUS
%
% The IRIS Toolbox 2008/02/20. Copyright 2007-2008 Jaromir Benes. <a href="http://www.iris-toolbox.com">www.iris-toolbox.com</a>
%

% ###########################################################################################################
%% function body

names = [vech(fieldnames(d1)),vech(fieldnames(d2))];
values = [vech(struct2cell(d1)),vech(struct2cell(d2))];
[names,index] = unique(names,'last');
d = cell2struct(values(index),names,2);

end

% end of primary function
% ###########################################################################################################