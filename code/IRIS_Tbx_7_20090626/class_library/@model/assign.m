function [m,assigned] = assign(m,varargin)
%
% To get help for this IRIS function
% * type <a href="matlab: idoc model.assign">idoc model.assign</a>, or
% * open <a href="matlab: helpbrowser">Matlab Product Help</a> and go the The IRIS Toolbox at the bottom of the Contents pane,
%
% The IRIS Toolbox 2008/05/05. Copyright 2007-2008 Jaromir Benes. <a href="http://www.iris-toolbox.com">www.iris-toolbox.com</a>

% ###########################################################################################################
%% function body

nalt = length(m);

assigned = [];
conflict = [];
invalid = [];

if nargin == 1
  % assign(m)

  return

elseif nargin == 2 && isnumeric(varargin{1})
  % assign(m,[1,2,...])

  list = 1 : length(m.name);
  if sum(size(varargin{1}) > 1) == 1
    value = vech(varargin{1});
    value(1,:,2:nalt) = value(1,:,ones([1,nalt-1]));
  else
    value = permute(varargin{1},[3,1,2]);
  end
  if all(size(value) == size(m.assign))
    m.assign(1,:,:) = value(1,:,:);
    assigned = 1 : length(m.name);
  end

elseif nargin == 2 && isstruct(varargin{1})
  % assign(m,d)

  list = fieldnames(varargin{1});
  if length(list) < length(m.name)
    for i = 1 : length(list)
      index = find(strcmp(m.name,list{i}));
      if ~isempty(index)
        assign_(index,varargin{1}.(list{i}));
      end
    end
  else
    for i = 1 : length(m.name)
      if isfield(varargin{1},m.name{i})
        assign_(i,varargin{1}.(m.name{i}));
      end
    end
  end

elseif nargin > 2 && all(cellfun(@(x) iscellstr(x) || ischar(x),varargin(1:2:end)))
  % assign(m,'a',1,'b',1,'c',2) or assign(m,'a,b',1,'c',2) or assign(m,{'a','b'},1,'c',2)

  for i = 1 : 2 : length(varargin)
    name = varargin{i};
    if ischar(varargin{i})
      name = charlist2cellstr(name);
    end
    assign_(matchnames_(m.name,name),varargin{i+1});
  end

else

  error('Incorrect type of input argument(s).');

end

if ~isempty(invalid)
  error_(46,m.name(unique(invalid)));
end

if nargout > 1
  assigned = m.name(unique(assigned));
end

% end of function body

% ###########################################################################################################
% nested function assign_()

   function assign_(index,value)

   nindex = length(index);
   value = vech(value);
   nvalue = length(value);

   if nindex == 0
    
    return

   elseif nindex == 1 || nvalue == 1
    % one name and possibly multiple values
    % or multiple names and one value

    if nvalue == nalt || nvalue == 1
      m.assign(1,index,:) = value;
      assigned = [assigned,index];
    else
      invalid = [invalid,index];
    end

   elseif nindex > 1 && nvalue == 1
    % multiple names
    % one value

    m.assign(1,index,:) = value;
    assigned = [assigne,index];

   elseif nindex > 1 && nvalue > 1
    % multiple names
    % multiple values

    if nvalue == nalt
      % all names have identical values
      % different for each parameterisation
      value = permute(value,[1,3,2]);
      m.assign(1,index,:) = value(1,ones([1,nindex]),:);
      assigned = [assigned,index];
    elseif nvalue == nindex
      % each name has its own value
      % identical for all parameterisations
      m.assign(1,index,:) = value(1,:,ones([1,nalt]));
      assigned = [assigned,index];
    else
      invalid = [invalid,index];
    end

   else

    invalid = [invalid,index];

   end

   end
   % end of nested function assign_()

% ###########################################################################################################
%% nested function matchnames_()

   function index = matchnames_(list,pattern)

   index = [];
   % find patterns that contain only a-zA-Z_
   % others are treated as regular expressions
   isregexp =  ~cellfun(@isempty,regexp(pattern,'\W','once','start'));
   for j = find(isregexp)
    index = [index,find(~cellfun(@isempty,regexp(list,sprintf('^(%s)$',pattern{j}),'start')))];
   end
   for j = find(~isregexp)
    index = [index,find(strcmp(list,pattern{j}))];
   end

   end
   % end of nested function matchnames_()

end
% end of primary function
