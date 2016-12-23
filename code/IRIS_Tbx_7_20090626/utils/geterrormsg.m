function msg = geterrormsg()

msg = getfield(lasterror(),'message');
msg = strrep(msg,char(10),'. ');
msg = strrep(msg,'Error using ==> evalin. ','');
msg = strrep(msg,'Error using ==> eval. ','');
msg = strrep(msg,'Error: ','');
msg = regexprep(msg,' for input arguments of type ''.*?''','');

end