function varargout = userdata(this,varargin)

if isempty(varargin)
   varargout{1} = this.userdata;
else
   this.userdata = varargin{1};
   varargout{1} = this;
end

end