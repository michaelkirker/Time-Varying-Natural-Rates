function this = resizeComments_(this)

sizeOfData = size(this.data);
sizeOfData(1) = [];
sizeOfComm = size(this.comment);
sizeOfComm(1) = [];
if length(sizeOfData) > length(sizeOfComm)
   sizeOfComm(end+1:length(sizeOfData)) = 1;
elseif length(sizeOfData) < length(sizeOfComm)
   sizeOfData(end+1:length(sizeOfComm)) = 1;
end
if all(sizeOfData == sizeOfComm)
   return
end

sizeMax = max([sizeOfData;sizeOfComm],[],1);
comment = cell([1,sizeMax]);
comment(:) = {''};
nsubs = length(sizeOfComm);
subs = cell([1,nsubs]);
for i = 1 : nsubs
   subs{i} = 1 : sizeOfComm(i);
end
comment(1,subs{:}) = this.comment;
subs = cell([1,nsubs]);
for i = 1 : nsubs
   subs{i} = 1 : sizeOfData(i);
end
this.comment = comment(1,subs{:});

end