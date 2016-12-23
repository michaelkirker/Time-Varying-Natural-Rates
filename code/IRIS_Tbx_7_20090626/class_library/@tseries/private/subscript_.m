function [flag,x,s,shift,range] = subscript_(x,s)
% SUBSCRIPT_  Called from within tseries/subsasgn and tseries/subsref.

% The IRIS Toolbox 2009/02/20.
% Copyright 2007-2009 Jaromir Benes.

%********************************************************************
%! Function body.

flag = true;
shift = 0;
range = [];

if isshift_(s(1))
   % First {} subscript is lag/lead.
   shift = s(1).subs{1};
   x.start = x.start - shift;
   s(1) = [];
end

if isempty(s)
   s = struct();
   s.type = '{}';
   s.subs = cell([1,ndims(x.data)]);
   s.subs(:) = {':'};
elseif length(s) > 1
   % only one () or {} subscript allowed on top of lag/lead
   flag = false;
   return
elseif length(s.subs) == 1
   % x(range) replaced with x(range,:,...,:)
   s.subs(2:ndims(x.data)) = {':'};
end

% Inf and ':' produce the whole tseries range.
% Convert subscripts in 1st dimension from dates to indices.
if strcmp(s.subs{1},':') || (isnumeric(s.subs{1}) && length(s.subs{1}) == 1 && isinf(s.subs{1}))
   s.subs{1} = ':';
   if isnan(x.start)
      % empty LHS series
      range = [];
   else
      range = x.start + (0 : size(x.data,1)-1);
   end
elseif isnumeric(s.subs{1}) && ~isempty(s.subs{1})
   range = s.subs{1};
   if isnan(x.start)
      % if LHS series is empty
      % set startdate to min(range)
      x.start = min(range);
      % NaNs will be padded appropriately
      % in last block
   end
   s.subs{1} = round(range - x.start + 1);
elseif isnumeric(s.subs{1}) && isempty(s.subs{1})
   range = [];
else
   flag = false;
   return
end

% expand data with NaNs when user indices go beyond the data size
% expand data in 1st dim with NaNs when user indices are non-positive
% expand comments with empty strings correspondingly
% this modifies standard Matlab matrix assignment which produces zeros
colon = strcmp(':',s.subs);
nsubs = length(s.subs);
for i = find(~colon)
   % non-positive index
   if any(s.subs{i} < 1)  
      % expand with NaNs in 1st dim
      if i == 1
         n = 1 - min(s.subs{1});
         aux = sizeof(x.data,nsubs);
         aux(1) = n;
         x.data = [nan(aux);x.data];
         x.start = x.start - n;
         s.subs{1} = s.subs{1} + n;
      else
         % throw error for higher dims
         flag = false;
         return
      end
   end
   % index goes beyond the date size
   if any(s.subs{i} > size(x.data,i))
      aux = sizeof(x.data,nsubs);
      aux(i) = max(s.subs{i}) - aux(i);
      x.data = cat(i,x.data,nan(aux));
   end
end

end
% End of primary function.

%********************************************************************
%! Subfunction isshift_().

function flag = isshift_(s)
   
flag = ...
   any(strcmp(s(1).type,'{}')) && ...
   length(s(1).subs) == 1 && ...
   length(s(1).subs{1}) == 1 && ...
   round(s(1).subs{1}) == s(1).subs{1} && ...
   ~isinf(s(1).subs{1});

end
% End of subfunction isshift_().