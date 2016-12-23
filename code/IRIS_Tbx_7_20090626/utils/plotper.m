function handle = plotper(per,varargin)

per = vech(per);
lambda = 2*pi ./ per;
ylim = vec(get(gca,'ylim'));
handle = plot([lambda;lambda],repmat(ylim,[1,length(per)]),varargin{1:end});

end