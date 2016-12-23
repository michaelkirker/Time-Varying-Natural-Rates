function list = printid_(m,type)
%
% MODEL/PRIVATE/PRINTID_  Write formatted strings for model variables.
%
% The IRIS Toolbox 2007/11/06. Copyright 2007 Jaromir Benes. <a href="http://www.iris-toolbox.com">www.iris-toolbox.com</a>
% _______________________________________________________________________________

if nargin < 2
  type = [1,2,3];
end

%% function body --------------------------------------------------------------------------------------------

list = printid(...
  m.name(real([m.solutionid{type}])),...
  imag([m.solutionid{type}]),...
  m.log(real([m.solutionid{type}]))...
);

end

%% end of primary function ----------------------------------------------------------------------------------