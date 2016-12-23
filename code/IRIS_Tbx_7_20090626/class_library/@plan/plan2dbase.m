function d = plan2dbase(p)
%
% PLAN2DBASE  Convert simulation plan to database.
%
% The IRIS Toolbox 2007/07/31. Copyright 2007 Jaromir Benes. <a href="http://www.iris-toolbox.com">www.iris-toolbox.com</a>

% function body ---------------------------------------------------------------------------------------------

d = dbmerge(p.exogenized,p.endogenized);

end % of primary function -----------------------------------------------------------------------------------