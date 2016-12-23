function list = missing(varargin)
%
% <a href="matlab: edit model/missing">MISSING</a>  Check source database or datapack for missing initial conditions.
%
% Syntax:
%    list = missing(m,source,range)
% Output arguments:
%    list [ cellstr ] List of initial conditions missing from input database.
% Required input arguments:
%    m [ model ] Model.
%    source [ struct ] Input database.
%    range [ numeric ] Simulation range, i.e. <a href="dates.html">IRIS serial date numbers</a>.
%
% The IRIS Toolbox 2008/04/22. Copyright 2007-2008 Jaromir Benes. <a href="http://www.iris-toolbox.com">www.iris-toolbox.com</a>
%

% ###########################################################################################################
% function body

[flag,list] = simulate(varargin{:},'checkonly',true);

end
% end of primary function