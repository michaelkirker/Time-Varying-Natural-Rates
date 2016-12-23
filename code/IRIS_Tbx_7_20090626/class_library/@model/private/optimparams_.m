function [m,list,p0,pl,pu,prior,pindex,notfound,invalidbounds,highinit,lowinit] = optimparams_(m,d)
% OPTIMPARAMS_  Get optimised paramters, their current values and bounds.

% The IRIS Toolbox 2009/02/19.
% Copyright 2007-2009 Jaromir Benes.

%********************************************************************
%! Function body.

fields = fieldnames(d);
pindex = [];
list = {};
p0 = [];
pl = [];
pu = [];
prior = {};

notfound = {};
invalidbounds = {};
highinit = {};
lowinit = {};

for i = 1 : length(fields)
   name_ = fields{i};
   pindex_ = sum(m.nametype < 4) + find(strcmp(m.name(m.nametype == 4),name_));
   if isempty(pindex_)
      notfound{end+1} = name_;
      continue
   end
   aux = d.(name_);
   if isnumeric(aux)
      aux = num2cell(aux);
   end
   if length(aux) > 0
      p0_ = aux{1};
   else
      p0_ = NaN;
   end
   if isnan(p0_)
      p0_ = m.assign(1,pindex_);
   end
   if length(aux) > 1
      pl_ = aux{2};
   else
      pl_ = -Inf;
   end
   if length(aux) > 2
      pu_ = aux{3};
   else
      pu_ = Inf;
   end
   if length(aux) > 3 && ~isempty(aux{4})
      prior_ = aux{4};
   else
      prior_ = [];
   end
   if pl_ > pu_
      invalidbounds{end+1} = name_;
      continue
   end
   if pl_ == pu_
      m.assign(1,pindex_) = pl_;
      continue;
   end
   if p0_ > pu_
      p0_ = pu_;
      highinit{end+1} = name_;
   elseif p0_ < pl_
      p0_ = pl_;      
      lowinit{end+1} = name_;
   end
   list{end+1} = name_;
   pindex(end+1) = pindex_;
   m.assign(1,pindex_) = p0_;
   p0(end+1) = p0_;
   pl(end+1) = pl_;
   pu(end+1) = pu_;
   prior{end+1} = prior_;
end

end
% End of primary function.