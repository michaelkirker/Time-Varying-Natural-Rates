function p = reportobject(type,spec,parentoptions,varargin)

p.type = '';
p.options = struct;
p.spec = NaN;

if nargin > 0
  p.type = type;
  if nargin > 1
    p.spec = spec;
    if nargin > 2
      p.options = readoptions_(parentoptions,varargin{:});
    end
  end
end

end