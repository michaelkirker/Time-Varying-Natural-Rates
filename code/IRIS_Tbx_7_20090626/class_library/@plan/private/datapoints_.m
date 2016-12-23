function [dbase1,dbase2,name] = datapoints_(modelname,dbase1,dbase2,name,range)
%
% The IRIS Toolbox 2007/05/03. Copyright 2007 Jaromir Benes. <a href="www.iris-toolbox.com">www.iris-toolbox.com</a>

% function body ---------------------------------------------------------------------------------------------

% endogenise residuals or exogenise measurement/transition variables
aux = tseries(range,@ones);
index = findnames(modelname,name);
name(~isnan(index)) = [];
index(isnan(index)) = [];
for i = index
  try % add new datapoints if name already exists in database
    dbase1.(modelname{i});
    dbase1.(modelname{i})(range) = 1;
  catch % otherwise create new field
    dbase1.(modelname{i}) = aux;
  end
end

% endogenise previously exogenised variables or exogenise previously endogenised residuals
list = vech(fieldnames(dbase2));
list(strmatch('IRIS_',list)) = [];
index = findnames(list,name);
name(~isnan(index)) = [];
index(isnan(index)) = [];
unable = {};
remove = {};
for i = index
  aux = dbase2.(list{i})(range) ~= 1;
  if any(aux), unable(end+1:end+2) = {list{i},range(aux)}; end
  dbase2.(list{i})(range) = nan(size(range));
  % remove from database if no data point
  if size(dbase2.(list{i}),1) == 0, remove{end+1} = list{i}; end
end
if ~isempty(remove), dbase2 = rmfield(dbase2,remove); end

end % of primary function -----------------------------------------------------------------------------------