classdef htmlreport < handle

%********************************************************************
   properties (Access = 'public')
   
      name = 'report';
      required = {};
      options = struct();
      parent = NaN;
      children = {};
      
   end

%********************************************************************   
   properties (Constant = true)
   
   inherited = {...
      'format','%.2f',@ischar,...
      'nan','&times;',@ischar,...
      'highlight',[],@isnumeric,...
      'dateformat',irisget('dateformat'),@ischar,...
      'stylesheet','htmlreportdefault.css',@ischar,...
      'mark',{},@(x) isempty(x) || ischar(x) || iscellstr(x),...
      'range',Inf,@isnumeric,...
      'subplot','auto',@(x) isnumeric(x) || strcmpi(x,'auto'),...
      'graphresolution',130,@isnumeric,...
   };
   specific = {...
      'emphasis',false,@islogical,...
      'caption','',@ischar,...
   };
   
   end

%********************************************************************      
   methods (Access = 'public')
   
      function this = htmlreport(varargin)
         if isempty(varargin) || ~isnumeric(varargin{1}) || ~any(isinf(varargin{1}))
            % htmlreport(varargin)
            parent = NaN;
            inherited = struct();
            % Reset inherited options.
            for i = 1 : 3 : length(this.inherited)
               inherited.(this.inherited{i}) = this.inherited{i+1};
            end
            name = 'report';
            nrequired = 0;
         else
            % htmlreport(Inf,parent,name,nrequired,varargin)
            parent = varargin{2};
            inherited = parent.options * parent.inherited(1:3:end);
            name = varargin{3};
            nrequired = varargin{4};
            varargin(1:4) = [];            
         end
         this.name = name;
         if length(varargin) < nrequired
            varargin(end+1:nrequired) = {[]};
         end
         this.required(1:nrequired) = varargin(1:nrequired);
         this.options = inherited;
         this = getoptions(this,varargin{nrequired+1:end});         
      end
      
      function display(this)
         x = findancestor(this,'report');
         disp(' ');
         display1(x,0,[]);
         disp(' ');
         function display1(x,level,last)
            indent = '';
            for i = 1 : level
               if i < level && last(i)
                  indent = [indent,'   '];
               else
                  indent = [indent,'  |'];
               end
            end
            if level > 0
               indent = [indent,'__.'];
            else
               indent = ['  .'];
            end
            disp([indent,'<a href="matlab:">',x.name,'</a> ',getshort(x)]);
            nchildren = length(x.children);
            for i = 1 : nchildren;
               thislast = i == nchildren;
               display1(x.children{i},level+1,[last,thislast]);
            end
         end
      end
      
      varargout = compile(this,varargin);      
      
   end

%********************************************************************   
   methods (Access = 'private')
      
      function this = newelement(this,callerName,parentName,nRequired,varargin)
         % First, climb up to root.
         this = findancestor(this,'report');
         % From there, find latest element.
         this = findlastchild(this);
         % Finally, climb up to find if one of the ancestors
         % can be the parent we need.
         thisParent = findancestor(this,parentName);
         if isnan(thisParent)
            error('iris:htmlreport','Cannot create "%s" here.',callerName);
         end
         this = htmlreport(Inf,thisParent,callerName,nRequired,varargin{:});
         thisParent.children{end+1} = this;
         this.parent = thisParent;
      end

      function this = findlastchild(this)
         while ~isempty(this.children)
            this = this.children{end};
         end
      end

      function x = findancestor(this,name)
         x = this;
         while ~isnan(x) && ~strcmp(x.name,name)
            x = x.parent;
         end     
      end

      function flag = isnan(this)
         flag = false;
      end

      function this = getoptions(this,varargin)
         if ~iscellstr(varargin(1:2:end))
            error('iris:htmlreport','Optional arguments must be pairs of names and values.');
         end
         % Add specific options.
         for i = 1 : 3 : length(this.specific)
            this.options.(this.specific{i}) = this.specific{i+1};
         end
         % Set user supplied options.
         unknown = {};
         for i = 1 : 2 : length(varargin)
            if isfield(this.options,varargin{i})
               this.options.(varargin{i}) = varargin{i+1};
            else
               unknown{end+1} = varargin{i};
            end
         end
         if ~isempty(unknown)
            tmp = cell([1,2*length(unknown)]);
            tmp(1:2:end) = unknown;
            tmp(2:2:end) = {this.name};
            warning('iris:htmlreport','Unrecognised option "%s" in "%s". Option not used.\n',tmp{:});
         end
         % Validate inherited options.
         invalid = {};
         for i = 1 : 3 : length(this.inherited)
            if ~feval(this.inherited{i+2},this.options.(this.inherited{i}))
               invalid{end+1} = this.inherited{i};
            end
         end
         % Validate specific options.
         for i = 1 : 3 : length(this.specific)
            if ~feval(this.specific{i+2},this.options.(this.specific{i}))
               invalid{end+1} = this.specific{i};
            end
         end
      end
      
      function short = getshort(this)
         switch this.name
         case 'report'
            short = '';
         case {'table','subheading','figure','graph'}
            short = this.required{1};
         case {'row','line'}
            short = this.required{2};
         otherwise
            short = '';
         end
         if ~isempty(short)
            short = ['''',short,''''];
         end
      end
   
   end   

%********************************************************************   
   methods (Access = 'public')
   
      function x = pagebreak(this,varargin)
         x = newelement(this,'pagebreak','report',0,varargin{:});
      end

      function x = figure(this,varargin)
         % Required input args:
         % caption         
         x = newelement(this,'figure','report',1,varargin{:});
      end

      function x = graph(this,varargin)
         % Required input args:
         % title
         x = newelement(this,'graph','figure',1,varargin{:});
      end
      
      function x = line(this,varargin)
         % Required input args:
         % data, text
         x = newelement(this,'line','graph',2,varargin{:});
      end

      function x = table(this,varargin)
         % Required input args:
         % caption
         x = newelement(this,'table','report',1,varargin{:});
      end

      function x = row(this,varargin)
         % Required input args:
         % data, text, units
         x = newelement(this,'row','table',3,varargin{:});
      end

      function x = subheading(this,varargin)
         % Required input args:
         % text
         x = newelement(this,'subheading','table',1,varargin{:});
      end
      
   end
   
end