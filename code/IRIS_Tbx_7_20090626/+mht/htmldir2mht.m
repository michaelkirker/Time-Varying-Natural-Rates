function htmldir2mht(input,outputFile,varargin)
% Convert HTML directory into MHT archive.

% The IRIS Toolbox 2009/04/25.
% Copyright (c) 2007-2009 Jaromir Benes.

default = {...
   'filetypes',{'.html','.png','.css'},@(x) isempty(x) || ischar(x) || iscellstr(x),...
};
options = passvalopt(default,varargin{:});

if ischar(options.filetypes)
   options.filetypes = charlist2cellstr(options.filetypes);
elseif isempty(options.filetypes)
   options.filetypes = {};
end

%********************************************************************
%! Function body.

if ischar(input)
   list = mht.filesin(input);
   list = {list(:).name};
   thisDir = input;
else
   list = input;
   thisDir = cd();   
end

heading1 = grabtext('==START OF HEADING 1==','==END OF HEADING 1==');
heading2 = grabtext('==START OF HEADING 2==','==END OF HEADING 2==');
tokens = regexp(heading1,'boundary="(.*?)"','once','tokens');
boundary = tokens{1};

newLine = char(10);
mhtFile = [heading1,newLine];
for i = 1 : length(list)
   % Full path to currently processed file
   thisFilename = fullfile(thisDir,list{i});
   % Name for base64-encoded file
   thisFilename64 = [thisFilename,'64'];
   x = heading2;
   thisExtension = mht.extensionof(list{i});
   if ~any(strcmp(thisExtension,options.filetypes))
      continue
   end
   switch thisExtension
   case '.html'
      x = strrep(x,'Content-Type:','Content-Type: text/html; charset="UTF-8"');
      encode = false;
   case '.png'
      x = strrep(x,'Content-Type:','Content-Type: image/png');
      encode = true;
   case '.css'
      x = strrep(x,'Content-Type:','Content-Type: text/css');
      encode = false;
   otherwise
      encode = true;
   end
   x = strrep(x,'Content-Location: file:///',['Content-Location: file:///',strrep(thisFilename,'\','/')]);
   if encode
      mht.base64('encode',thisFilename,thisFilename64);
      thisFile = file2char(thisFilename64);
      delete(thisFilename64);
   else
      thisFile = file2char(thisFilename);
      x = strrep(x,' base64','');
   end
   thisFile = strrep(thisFile,char(13),'');
   mhtFile = [mhtFile,newLine,['--',boundary],newLine,x,newLine,newLine,thisFile,newLine];
end

mhtFile = [mhtFile,newLine,newLine,['--',boundary,'--']];
char2file(mhtFile,outputFile);

end
% End of primary function.
  
%{

==START OF HEADING 1==
From: 
Subject: 
Date: 
MIME-Version: 1.0
Content-Type: multipart/related;
	boundary="----=_NextPart_0000_0000_0000_0000";
	type="text/html"
==END OF HEADING 1==

==START OF HEADING 2==
Content-Type: 
Content-Transfer-Encoding: base64
Content-Location: file:///
==END OF HEADING 2==

%}
