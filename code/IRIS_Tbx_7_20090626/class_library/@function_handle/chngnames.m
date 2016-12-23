function chngnames(input,output,replace)

x = file2char(char(input));
x = chngnames(x,replace);
char2file(x,char(output));

end