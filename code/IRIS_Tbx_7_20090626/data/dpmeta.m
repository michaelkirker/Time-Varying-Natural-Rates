function [yname,xname,ename,ylog,xlog,xshift] = dpmeta(meta)
%
% DPMETA  Fetch metadata from datapack.
%
% The IRIS Toolbox 2007/06/19. Copyright 2007 <a href="mailto:jaromir.benes@gmail.com?subject=The%20IRIS%20Toolbox%3A%20%5Byour%20subject%5D">Jaromir Benes</a>. <a href="www.iris-toolbox.com">www.iris-toolbox.com</a>

% ###########################################################################################################
% function body

pattern = '(log\()?(\w+)(\{[\+-]?\d+\})?(?(1)\))';

% measurement variables
if isfield(meta,'yvector')
  % G5 metadata structure
  tokens = regexp(meta.yvector,pattern,'tokens','once');
  tokens = [tokens{:}];
  if isempty(tokens)
    ylog = [];
    yname = {};
  else
    ylog = ~cellfun(@isempty,tokens(1:4:end));
    yname = tokens(2:4:end);
  end
else
  % G4 metadata structure
  yid = meta.id{1};
  yname = meta.name(real(yid));
  ylog = meta.log(real(yid));
end

% transition variables
if isfield(meta,'xvector')
  % G5 metadata structure
  tokens = regexp(meta.xvector,pattern,'tokens','once');
  tokens = [tokens{:}];
  xlog = ~cellfun(@isempty,tokens(1:4:end));
  xname = tokens(2:4:end);
  xshift = tokens(3:4:end);
  xshift(cellfun(@isempty,xshift)) = {'{0}'};
  xshift = vech(sscanf([xshift{:}],'{%g}'));
else
  % G4 metadata structure
  xid = meta.id{2};
  xname = meta.name(real(xid));
  xlog = meta.log(real(xid));
  xshift = imag(xid);
end

% residual variables
if isfield(meta,'evector')
  % G5 metadata structure
  tokens = regexp(meta.evector,pattern,'tokens','once');
  tokens = [tokens{:}];
  if isempty(tokens)
    ename = {};
  else
    ename = tokens(2:4:end);
  end
else
  % G4 metadata structure
  eid = meta.id{3};
  ename = meta.name(real(eid));
end

end
% end of primary function