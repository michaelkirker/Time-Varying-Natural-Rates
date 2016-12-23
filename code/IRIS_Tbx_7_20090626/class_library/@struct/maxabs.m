function x = maxabs(d,varargin)

x = [];
list = fieldnames(d);
for i = 1 : length(list)
   try
      if nargin == 1
         tmp = maxabs(d.(list{i}));
      else
         tmp = maxabs(d.(list{i}) - varargin{1}.(list{i}));
      end
      x = max([x,tmp]);
   end
end
   
end