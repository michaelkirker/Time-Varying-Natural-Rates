function flag = isdpack(this)

flag = iscell(this) || (isstruct(this) && isfield(this,'mean') && isfield(this,'mse') && iscell(this.mean));

end
