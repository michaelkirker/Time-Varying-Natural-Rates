function handle = baracf(c,x,y,varargin)

order = size(c,3) - 1;
aux = [vech(c(x,y,end:-1:1)),vech(c(y,x,2:end))];
handle = bar(-order:order,aux,varargin{:});

end