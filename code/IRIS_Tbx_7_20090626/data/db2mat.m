function [mat,notfound,invalid] = db2mat(d,range,name,shift,loglin)
%
% The IRIS Toolbox 2007/05/03. Copyright 2007 Jaromir Benes. <a href="www.iris-toolbox.com">www.iris-toolbox.com</a>
%

%%

if nargin < 4
   shift = zeros(size(name));
end

if nargin < 5
   loglin = false(size(name));
end

% ===========================================================================================================
%% function body

notfound = {};
invalid = {};
range = range(1) : range(end);
nper = length(range);
minshift = min(shift);
pointer = nan(size(name));
track = false(size(name));
X = zeros([0,-minshift+nper]);
for i = 1 : length(name)
   % name already processed in previous iterations
   if track(i)
      continue;
   end
   % find all occurences of name
   index = strcmp(name,name{i});
   % indicate that all occurences are processed now
   track(index) = true;
   % catch if name is not an existing time series
   if isfield(d,name{i}) && istseries(d.(name{i}))
      tmp = d.(name{i})(range(1)+minshift:range(end));
      dim = size(tmp);
      % squeeze ND arrays into 2D nper x ndata arrays
      tmp = reshape(tmp,[dim(1),prod(dim(2:end))]);
      % reshape into 1 x nper x ndata
      tmp = permute(tmp,[3,1,2]);
   else
      notfound{end+1} = name{i};
      continue
   end
   % check size of X and tmp before splicing them
   if size(X,3) ~= size(tmp,3)
      % expand X if it is scalar
      if size(X,3) == 1
         X = X(:,:,ones([1,size(tmp,3)]));
         % expand tmp if it is scalar
      elseif size(tmp,3) == 1
         tmp = tmp(:,:,ones([1,size(X,3)]));
         % otherwise treat as invalid
      else
         invalid{end+1} = name{i};
         continue,
      end
   end
   if issingle(tmp)
      X = [single(X);tmp];
   else
      X = [double(X);tmp];
   end
   % set pointers of all occurences to current row of X
   pointer(index) = size(X,1);
end

nalt = size(X,3);
mat = nan([length(name),nper,nalt],class(X));

t = (1 : nper) - minshift;
for i = 1 : length(name)
   if shift(i) <= 0 && ~isnan(pointer(i))
      mat(i,:,:) = X(pointer(i),t+shift(i),:);
   end
end

if ~isempty(invalid)
   invalid = unique(invalid);
end

if ~isempty(notfound)
   notfound = unique(notfound);
end

end
% end of primary function