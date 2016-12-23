function multierror(format,list,errorid)

if isempty(list)
  return
end

if nargin < 3
   errorid = 'iris:general';
end

formats = cell(size(list));
formats(1:end-1) = {[format,'\n']};
formats{end} = format;

% remove multierror from the stack of functions
stack = dbstack('-completenames');
if ~isempty(stack)
   stack(1) = [];   
end

if isempty(stack)
   error(struct('message',sprintf([formats{:}],list{:}),'identifier',errorid));
else
   error(struct('message',sprintf([formats{:}],list{:}),'identifier',errorid,'stack',stack));
end

end