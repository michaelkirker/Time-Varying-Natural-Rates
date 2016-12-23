function varargout = isname(m,varargin)

for i = 1 : length(varargin)
   index = strcmp(m.name,varargin{i});
   if any(index)
      varargout{i} = m.nametype(index);
   else
      varargout{i} = false;
   end
end

end