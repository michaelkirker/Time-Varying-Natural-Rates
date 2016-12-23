function [plist,pindex1,pindex2] = getpindex_(this,list)
% GETPARAMETERS  Get parameter indices and check for non-existent names.

% The IRIS Toolbox 2009/04/09.
% Copyright 2007-2009 Jaromir Benes.

if ischar(list)
   list = charlist2cellstr(list);
end

%********************************************************************
%! Function body.

% Get plist, pindex1, pindex2 so that:
% plist{i} == this.name{pindex1(i)},
% plist{i} == list{pindex2(i)}.
tmp = this.name;
tmp(this.nametype ~= 4) = {''};
[plist,pindex1,pindex2] = intersect(tmp,list);

% Check list for non-existent parameter names.
list(pindex2) = [];
if ~isempty(list)
   warning_(31,list);
end

end
% End of primary function.