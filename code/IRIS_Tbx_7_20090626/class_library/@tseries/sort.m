function [x,index] = sort(x,crit)

switch crit
case 'sumsq'
  [ans,index] = sort(sum(x.data.^2,1),'descend');
case 'sumabs'
  [ans,index] = sort(sum(abs(x.data),1),'descend');
case 'max'
  [ans,index] = sort(max(x.data,[],1),'descend');
case 'maxabs'
  [ans,index] = sort(max(abs(x.data,[],1)),'descend');
case 'min'
  [ans,index] = sort(min(x.data,[],1),'ascend');
end

x.data = x.data(:,index);
x.comment = x.comment(index);

end