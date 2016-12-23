function x = irisversion()
fid = fopen(fullfile(irisget('irisroot'),'irisversion'),'r');
x = fgetl(fid);
fclose(fid);
end