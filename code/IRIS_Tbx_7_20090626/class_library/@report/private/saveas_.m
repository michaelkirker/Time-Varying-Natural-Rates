function saveas_(contents,blockcode,footcode)

char2file(blockcode,sprintf('%s.tex',contents{1}.options.saveas));
char2file(footcode,sprintf('%s-footnote.tex',contents{1}.options.saveas));

end