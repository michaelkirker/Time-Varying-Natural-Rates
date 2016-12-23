function stdvec = stdvec_(m,d,range)

[ny,nx,nf,nb,ne,np,nalt] = size_(m);
range = range(1) : range(end);
nper = length(range);

% Stdevs in model object.
stdvec = m.assign(1,end-ne+1:end,:);
stdvec = permute(stdvec,[2,1,3]); % 1 x ne x nalt -> ne x 1 x nalt
stdvec = stdvec(:,ones([1,nper]),:); % ne x 1 x nalt -> ne x nper x nalt

if isempty(d) || ~isstruct(d)
   return
end%if

% User-supplied stdevs.
list = m.name(m.nametype == 3);
stdvec2 = nan([0,nper,1]);
for i = 1 : length(list)
   stdname = sprintf('std_%s',list{i});
   if isfield(d,stdname) && istseries(d.(stdname))
      x = rangedata(d.(stdname),range);
      x = permute(x,[3,1,2]); % nper x nstd x 1 -> 1 x nper x nstd
      if ~isempty(stdvec2) && size(x,3) > size(stdvec2,3)
         stdvec2 = cat(3,stdvec2,stdvec2(:,:,end*ones([1,size(x,3)-size(stdvec2,3)])));
      elseif ~isempty(stdvec2) && size(x,3) < size(stdvec2,3)
         x = cat(3,x,x(:,:,end*ones([1,size(stdvec2,3)-size(x,3)])));
      end%if
      stdvec2 = [stdvec2;x];
   else
      stdvec2 = [stdvec2;nan([1,nper,size(stdvec2,3)])];
   end%if
end%for

% Make sure size of stdvec and size of stdvec2 are the same.
if size(stdvec,3) > size(stdvec2,3)
   stdvec2 = cat(3,stdvec2,stdvec2(:,:,end*ones([1,size(stdvec,3)-size(stdvec2,3)])));
elseif size(stdvec2,3) > size(stdvec,3)
   stdvec = cat(3,stdvec,stdvec(:,:,end*ones([1,size(stdvec2,3)-size(stdvec,3)])));
end%if

% Overwrite stdvec with non-NaNs from stdvec2.
stdvec(~isnan(stdvec2)) = stdvec2(~isnan(stdvec2));

end%function
% End of primary function.