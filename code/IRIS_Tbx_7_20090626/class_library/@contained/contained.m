function this = contained(varargin)

this = struct();
this.userdata = [];

if ~isempty(varargin)
   this.userdata = varargin{1};
end

this = class(this,'contained');

end