function epstopdf(list,options)
% EPSTOPDF  Run TeX's EPSTOPDF to convert EPS to PDF.

% The IRIS Toolbox 2009/03/03.
% Copyright 2007-2009 Jaromir Benes.

%********************************************************************
%! Function body.

if nargin == 1
   options = '';
end

if ischar(list)
   list = charlist2cellstr(list);
end

thisdir = cd();
epstopdf = irisget('epstopdfpath');
for i = 1 : length(list)
   [fpath,ftitle,fext] = fileparts(list{i});
   fpath = strtrim(fpath);
   if ~isempty(fpath)
      cd(fpath);
   end
   tmp = dir([ftitle,fext]);
   tmp([tmp.isdir]) = [];
   for j = 1 : length(tmp)
      disp(fullfile(fpath,tmp(j).name));
      system([epstopdf,' ',tmp(j).name,' ',options]);
   end
   cd(thisdir);
end

end
% End of primary function.

% '--enlarge=10' adds 10pt margins around.
