function qstyle(gs,h,varargin)

default = {...
   'cascade',true,@islogical,...
};
options = passvalopt(default,varargin{:});

if ischar(gs)
   % Remove extension.
   [fpath,ftitle,fext] = fileparts(gs);
   gs = rungsf_(fullfile(fpath,ftitle));
end

for i = vech(h)
   if ~ishandle(i)
      continue
   end
   switch get(i,'type')
   case 'figure'
      figure_(i,gs,options);
   case 'axes'
      axes_(i,gs,options);
   case 'line'
      line_(i,gs,options);
   end
end

end

%********************************************************************
%! Subfunction rungsf_().
% Run graphic style file and create graphic style database.

function d = rungsf_(gsf)
   axes = [];
   figure = [];
   label = [];
   line = [];
   title = [];
   run(gsf);
   d = struct();
   d.axes = axes;
   d.figure = figure;
   d.label = label;
   d.line = line;
   d.title = title;
end

%********************************************************************
%! Subfunction applyto_(h,d)

function applyto_(h,d,field)

   if isempty(h)
      return
   end
      
   if ~isfield(d,field) || ~isstruct(d.(field))
      return
   end
   
   nh = length(h);
   list = fieldnames(d.(field));
   for i = 1 : length(list)
      x = d.(field).(list{i});
      if ~iscell(x)
         x = {x};
      end
      nx = length(x);
      for j = 1 : nh
         if j <= nx
            value = x{j};
         else
            value = x{end};
         end
         try
            set(h(j),list{i},value);
         catch
            warning('Error setting %s property "%s".',field,list{i}); 
         end
      end
   end
end

%********************************************************************
%! Subfunction figure_().

function figure_(h,d,options)

   if isempty(h)
      return
   end      
   h = vech(h);
   applyto_(h,d,'figure');
   
   if ~options.cascade
      return
   end
   
   for i = h
      axes_(vech(findobj(i,'type','axes')),d,options);
   end
   
end
% End of subfunction figure_().

%********************************************************************
%! Subfunction axes_().

function axes_(h,d,options)
   
   if isempty(h)
      return
   end
   h = vech(h);
   applyto_(h,d,'axes');
      
   if ~options.cascade
      return
   end
   
   for i = h
      applyto_(get(i,'title'),d,'title');
      applyto_(get(i,'xlabel'),d,'label');
      applyto_(get(i,'ylabel'),d,'label');
      applyto_(get(i,'zlabel'),d,'label');
      line_(vech(findobj(i,'type','line')),d);
   end
      
end
% End of subfunction axes_().

%********************************************************************
%! Subfunction line_().

function line_(h,d,options)

   if isempty(h)
      return
   end   
   h = vech(h);
   applyto_(h(end:-1:1),d,'line');
      
end
% End of subfunction line_().