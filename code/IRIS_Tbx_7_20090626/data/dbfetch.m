function this = dbfetch(this,index)
% Fetch subset of data alternatives.

% The IRIS Toolbox 2008/10/03.
% Copyright (c) 2007-2008 Jaromir Benes.

%********************************************************************
%! Function body.

list = fieldnames(this);
for i = 1 : length(list)
   if istseries(this.(list{i}))
      this.(list{i}) = this.(list{i}){:,index};
   elseif isnumeric(this.(list{i})) || islogical(this.(list{i})) || iscell(this.(list{i}))
      try
         this.(list{i}) = this.(list{i})(:,index);
      end
   end
end

end
% End of primary function.