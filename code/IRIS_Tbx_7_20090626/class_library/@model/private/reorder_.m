function m = reorder_(m)
% REORDER_  Rearrange model equations into recursive blocks. Used to compute steady state.

% The IRIS Toolbox 2009/01/26.
% Copyright 2007-2009 Jaromir Benes.

%********************************************************************
%! Function body.

if issparse(m.occur)
  m.occur = reshape(full(m.occur),[size(m.occur,1),length(m.name),size(m.occur,2)/length(m.name)]);
end

[reordName,reordEqtn] = deal(cell([1,2]));
[reordName{2},reordEqtn{2}] = reorder1_(any(m.occur(m.eqtntype == 2,m.nametype == 2,:),3));
if any(m.nametype == 1)
  [reordName{1},reordEqtn{1}] = reorder1_(any(m.occur(m.eqtntype == 1,m.nametype == 1,:),3));
else
  [reordName{1},reordEqtn{1}] = deal(zeros([1,0]));
end

m.nameorder = [reordName{1},sum(m.nametype == 1) + reordName{2}];
m.eqtnorder = [reordEqtn{1},sum(m.eqtntype == 1) + reordEqtn{2}];

m.occur = sparse(m.occur(:,:));

end
% End of primary function.

%********************************************************************
%! Subfunction reorder1_().

function [reordName,reordEqtn] = reorder1_(occur)

  [nEqtn,nName] = size(occur);

  [aux,reordEqtn] = sort(vech(-sum(occur,2)));
  [aux,reordName] = sort(sum(occur,1));

  reordName0 = zeros(size(reordName));
  reordEqtn0 = zeros(size(reordEqtn));

  count = 0;

  while (any(reordName ~= reordName0) || any(reordEqtn ~= reordEqtn0)) && count < 500
    reordName0 = reordName;
    reordEqtn0 = reordEqtn;
    tmp = occur(reordEqtn,reordName);
    tmpReord = 1 : nName;
    for iEqtn = nEqtn : -1 : 1
      aux = find(tmp(iEqtn,:));
      tmp(:,aux) = true;
      aux = [find(~tmp(iEqtn,:)),aux];
      tmpReord(:) = tmpReord(aux);
      tmp = tmp(:,aux);
    end
    reordName(:) = reordName(tmpReord);
    tmp = occur(reordEqtn,reordName);
    tmpReord = 1 : nEqtn;
    for iName = 1 : nName
      aux = transpose(find(tmp(:,iName)));
      tmp(aux,:) = true;
      aux = [aux,transpose(find(~tmp(:,iName)))];
      tmpReord(:) = tmpReord(aux);
      tmp = tmp(aux,:);
    end
    reordEqtn(:) = reordEqtn(tmpReord);
    count = count + 1;
  end

end
% End of subfunction reorder1_().