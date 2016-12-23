function list = printnames(ids,names,logs)
%
% UTILS/PRINTNAMES  Cellstr of formatted variable names.
%
% IR!S Toolbox November 28, 2005 

% -----function PRINTNAMES body----- %

list = cell([1,0]);
for i = ids
  time = iff(imag(i) ~= 0,sprintf('{%g}',imag(i)),'');
  list{end+1} = sprintf(iff(logs(real(i)) == true,'log(%s%s)','%s%s'),names{real(i)},time);
end

end