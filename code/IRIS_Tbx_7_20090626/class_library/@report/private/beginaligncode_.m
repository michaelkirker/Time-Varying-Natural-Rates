function [code,alignmax] = beginaligncode_(options)

alignmax = options.horizontal;
aux = repmat(iff(options.centering,'c','r'),[1,alignmax]);
code = sprintf('{%s#begin{tabular}{%s}\n',iff(options.centering,'#centering',''),aux);

end