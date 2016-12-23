function [code,footnote] = graphcode_(options,contents,footnote,align);

tag = [];
for i = 2 : length(contents)-1
  switch contents{i}.type
  case 'tag'
    tag = contents{i};
  end
end

char2file(contents{end}.spec{2},contents{end}.spec{1});
code = sprintf('{#includegraphics[scale=%g,angle=%g]{%s}}',options.scale,options.angle,contents{end}.spec{1});
[code,footnote] = tagcode_(code,options,tag,footnote);
code = embrace_(code,options,align);

end