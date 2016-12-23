function result= dlmread_(file,delimiter)

delimiter = sprintf(delimiter);
 whitespace  = setdiff(sprintf(' \b\r\t'),delimiter);
result = dataread('string',file,'',-1,'delimiter',delimiter,'whitespace',whitespace, ...
       'headerlines',0,'headercolumns',0,'emptyvalue',NaN,'commentstyle','matlab');

end