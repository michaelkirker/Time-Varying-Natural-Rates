function flag = isdiag(X)
%
% <a href="utils/isdiag">ISDIAG</a>  True if matrix is diagonal.
%
% Syntax:
%   flag = isdiag(X)
% Output arguments:
%   flag [ true | false ] True if input matrix in diagonal.
% Required input arguments:
%   X [ numeric ] Tested matrix.
%
% The IRIS Toolbox 2007/08/23. Copyright 2007 Jaromir Benes. <a href="http://www.iris-toolbox.com">www.iris-toolbox.com</a>

%% function body --------------------------------------------------------------------------------------------

flag = all(all(tril(X,-1) == 0)) && all(all(triu(X,1) == 0));

end

%% end of primary function ----------------------------------------------------------------------------------