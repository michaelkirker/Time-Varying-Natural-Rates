function [p,pkg,cls,usr] = genpathcell(root,includeroot,pattern)

p = {};
pkg = {}; % package directories
cls = {}; % class directories
usr = {}; % user-defined directories

if nargin < 1
  return
end

if nargin < 2
   includeroot = true;
end

if nargin < 3
   pattern = '';
end

if includeroot
   p{end+1} = root;
end

list = dir(root);
if isempty(list)
  return
end

% Select only directories.
list = list([list.isdir]);

for i = 1 : length(list)
   name = list(i).name;
   if ~isempty(regexp(name,pattern,'start','once'))
      % Add user-defined directory.
      usr{end+1} = fullfile(root,name);
   elseif ~strcmp(name,'.') && ~strcmp(name,'..') && ~strcmp(name,'private') && ~strncmp(name,'@',1) && ~strncmp(name,'+',1)
      p = [p,genpathcell(fullfile(root,name),true,pattern)];
   elseif strncmp(name,'+',1)
      % Add package directory.
      pkg{end+1} = fullfile(root,name);
   elseif strncmp(name,'@',1)
      % Add class directory.
      cls{end+1} = fullfile(root,name); 
   end
end

end
