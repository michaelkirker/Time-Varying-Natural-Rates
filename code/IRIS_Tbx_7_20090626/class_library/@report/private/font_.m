function font = font_(embraceoptions,options)

if nargin == 1
  options = p.options;
end
if nargin < 3
  isglobal = false;
end

[font,fontsize,fontseries,fontshape] = deal('');
flag = false;

if strcmp(options.fontsize,'normal'), options.fontsize = 'normalsize'; end

list = {'tiny','small','normalsize','large','Large','LARGE'};
if any(strcmp(options.fontsize,list))
  fontsize = sprintf('#%s',options.fontsize);
  flag = true;
end

if isempty(embraceoptions) || options.bold ~= embraceoptions.bold
  fontseries = sprintf('#fontseries{%s}',iff(options.bold == true,'b','m'));
  flag = true;
end
if isempty(embraceoptions) || options.smallcaps ~= embraceoptions.smallcaps || options.italic ~= embraceoptions.italic
  fontshape = sprintf('#fontshape{%s}',iff(options.smallcaps == true,'sc',iff(options.italic == true,'it','n')));
  flag = true;
end
if flag
  font = sprintf('%s%s%s#selectfont',fontsize,fontseries,fontshape);
end  

end