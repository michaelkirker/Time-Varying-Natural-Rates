function [s,flag] = chksubsref_(s,n)
% CHKSUBSREF_  Check and re-organise subscripted reference in SUBSREF and SUBSASGN.

% The IRIS Toolbox 2009/04/28.
% Copyright 2007-2009 Jaromir Benes.

%********************************************************************
%! Function body.

% Chksubsref accepts
%   x(index)
%   x.name
%   x.(index)
%   x.name(index)
%   x(index).name(index)
% where index is either logical or numeric or ':'
% and returns
%   x(numeric)
%   x.name(numeric)

% Convert x(index1).name(index2) to x.name(index1(index2)).

if length(s) == 3 && any(strcmp(s(1).type,{'()','{}'})) && strcmp(s(2).type,{'.'}) && any(strcmp(s(3).type,{'()','{}'}))
   % convert a(index1).name(index2) to a.name(index1(index2))
   index1 = s(1).subs{1};
   if strcmp(index1,':')
      index1 = 1 : n;
   end
   index2 = s(3).subs{1};
   if strcmp(index2,':');
      index2 = 1 : length(index1);
   end
   s(1) = [];
   s(2).subs{1} = index1(index2);
end

% Convert a(index).name to a.name(index).

if length(s) == 2 && any(strcmp(s(1).type,{'()','{}'})) && strcmp(s(2).type,{'.'})
   s = s([2,1]);
end

if length(s) > 2
   error('Invalid reference to model object.');
end

% Convert a(:) or a.name(:) to a(1:n) or a.name(1:n).
% Convert a(logical) or a.name(logical) into a(numeric) or a.name(numeric).

if any(strcmp(s(end).type,{'()','{}'}))
   if strcmp(s(end).subs{1},':')
      s(end).subs{1} = 1 : n;
   elseif islogical(s(end).subs{1})
      s(end).subs{1} = vech(find(s(end).subs{1}));
   end
end

% Throw error for mutliple indices
% a(index1,index2,...) or a.name(index1,index2,...).

if any(strcmp(s(end).type,{'()','{}'}))
   if length(s(end).subs) ~= 1 || ~isnumeric(s(end).subs{1})
      error('Invalid reference to model object.');
   end
end

% Throw error if index is not real positive integer.

if any(strcmp(s(end).type,{'()','{}'}))
   index = s(end).subs{1};
   if any(index < 1) || any(round(index) ~= index) || any(imag(index) ~= 0)
      error('Subscript indices must either be real positive integers or logicals.');
   end
end

end
% End of primary function.