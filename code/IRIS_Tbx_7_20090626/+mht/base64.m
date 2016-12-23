function base64(action,inputFile,outputFile)

thisDir = fileparts(mfilename('fullpath'));
command = fullfile(thisDir,'base64.exe');
command = [command,' -',action(1),' "',inputFile,'" "',outputFile,'"'];
system(command);

end