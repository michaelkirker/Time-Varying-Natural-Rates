function varargout = loghpf(varargin)

for i = find(cellfun(@istseries,varargin))
  varargin{i} = log(varargin{i});
end

[varargout{1:nargout}] = hpf(varargin{:});

for i = 1 : length(varargout)
  varargout{i} = exp(varargout{i});
end

end