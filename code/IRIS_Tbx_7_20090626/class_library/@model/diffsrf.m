function s = diffsrf(m,nper,plist,varargin)
%
% To get help for this IRIS function
% * type <a href="matlab: idoc model.diffsrf">idoc model.diffsrf</a>, or
% * open <a href="matlab: helpbrowser">Matlab Product Help</a> and go the The IRIS Toolbox at the bottom of the Contents pane,
%
% The IRIS Toolbox 2008/05/05. Copyright 2007-2008 Jaromir Benes. <a href="http://www.iris-toolbox.com">www.iris-toolbox.com</a>

%!

if ischar(plist)
   plist = charlist2cellstr(plist);
end

% ===========================================================================================================
%! function body

[ny,nx,nf,nb,ne,np,nalt] = size_(m);
if nalt > 1
   error_(47,{'DIFFSFR'});
end

index = findnames(m.name(m.nametype == 4),plist);
if any(isnan(index))
   plist(isnan(index)) = [];
   index(isnan(index)) = [];
end
index = index + sum(m.nametype < 4);

% find optimal step for one-sided derivatives
p = m.assign(1,index);
n = length(p);
h = eps^(1/2)*max([p;ones(size(p))],[],1);

% assign alternative parameterisations p(i)+h(i) 
m = set(m,'nalt',n+1);
p = p(1,:,ones([1,1+n]));
for i = 1 : n
   p(1,i,1+i) = p(1,i,1) + h(i);
end
m = assign(m,plist,p);
m = solve(m);

% simulate SRF for all parameterisations
s = srf(m,nper,varargin{:});

% divide each simulation by the size of the step
for i = find(m.nametype <= 3)
   x = s.(m.name{i})(1:nper,:,:);
   comments = comment(s.(m.name{i}));
   for j = 1 : n
      if m.log(i)
         x(:,:,1+j) = (x(:,:,1+j) ./ x(:,:,1)) .^ (1/h(j));
      else
         x(:,:,1+j) = (x(:,:,1+j) - x(:,:,1)) / h(j);
      end
      comments(1,:,1+j) = regexprep(comments(1,:,1+j),'(.)$',sprintf('$1/%s',plist{j}));
   end
   s.(m.name{i})(1:nper,:,:) = x;
   s.(m.name{i}) = comment(s.(m.name{i}),comments);
end

end
% end of primary function