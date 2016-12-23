function filewrite(char,fname)
% FILEWRITE  Write character string to text file.

% The IRIS Toolbox 2009/04/09.
% Copyright 2007-2009 Jaromir Benes.

%********************************************************************
%! Function body.

if ~ischar(fname)
   fname = char(fname);
end

fid = fopen(fname,'w+');
if fid == -1
  error('IRIS:filewrite:cannotOpenFile','Cannot open file "%s" for writing.',fname);
end

count = fwrite(fid,char,'char');
if count ~= length(char)
   fclose(fid);
   error('IRIS:filewrite:cannotWrite','Cannot write character string to file "%s".',fname);
end

fclose(fid);

end
% End of primary function.