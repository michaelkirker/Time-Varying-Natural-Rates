function error_(code,list,varargin)

if iswarning('plan') == false, return, end

switch code

end

if nargin == 1, list = {}; end

printmsg('plan','error',msg,list,code);

end