function this = set(this,varargin)
% <a href="model/set">SET</a>  Set model object attributes and properties.
%
% Syntax:
%   this = set(this,attrib,value,attrib,value,...)
% Output arguments:
%   this [ model ] Model with changed attributes and/or properties.
% Required input arguments:
%   this [ model ] Model.
%   attrib [ char ] Attribute or property to be changed.
%   value [ any ] New value for the respective attribute or property.
% Attributes:
%   'NAlt' [ numeric ] Number of alternative parameterisations.
%   'StdVec' [ numeric ] Vector of std deviations.
%   'SSLevel' [ numeric ] Steady-state levels for measurement and/or transition variables.
%   'SSGrowth' [ numeric ] Steady-state growth rates for measurement and/or transition variables.
%   'TOrigin' [ numeric ] Base year for deterministic time trends in measurement variables.
%   'UserData' [ any ] User data.

% The IRIS Toolbox 2009/04/01.
% Copyright 2007-2009 Jaromir Benes.

if ~iscellstr(varargin(1:2:end))
  error('Incorrect type of input argument(s).');
end

%********************************************************************
%! Function body.

[ny,nx,nf,nb,ne,np,nalt] = size_(this);
unrecognized = {};
varargin(1:2:end) = strtrim(varargin(1:2:end));

for i = 1 : 2 : length(varargin)
   attribute = lower(varargin{i});
   value = varargin{i+1};
   
   switch attribute
   
   case {'sslevel','level','sstatelevel','ssgrowth','growth','sstategrowth'}
      for j = find(this.nametype <= 2)
         name = this.name{j};
         if isfield(value,name)
            level = real(this.assign(1,j,:));
            growth = imag(this.assign(1,j,:));
            if ~isempty(strfind(attribute,'level'))
               level(:) = real(value.(name));
            else
               growth(:) = real(value.(name));
            end
            this.assign(1,j,:) = complex(level,growth);
         end
      end

   case {'nalt','nalter'}
      this = nalter(this,value);

   case 'stdvec'
      this.assign(1,end-sum(this.nametype == 3)+1:end,:) = value;

   case 'torigin'
      this.torigin = iff(isempty(value),2000,round(value));

   case 'userdata'
      this.userdata = value;

   case 'epsilon'
      this.epsilon = value;

   case {'label','labels'}
      for i = 1 : 2
         this.eqtnlabel(this.eqtntype == i) = value{i};
      end
      nonemptyeqtn = ~cellfun(@isempty,this.eqtn);
      this.eqtnlabel(this.eqtntype == 3 & nonemptyeqtn) = value{3};
      this.eqtnlabel(this.eqtntype == 4 & nonemptyeqtn) = value{4};

   case {'xlabel','xlabels','ylabel','ylabels'}
      index = find(attribute(1) == 'yx');
      this.eqtnlabel(this.eqtntype == index) = value;
      
   case {'dlabel','dlabels','llabel','llabels'}
      index = 2 + find(attribute(1) == 'dl');
      this.eqtnlabel(this.eqtntype == index & ~cellfun(@isempty,this.eqtn)) = value;

   case {'rlabel','rlabels'}
      this.outside.label = value;

   case {'comment','comments'}
      for i = 1 : length(this.name)
         if isfield(value,this.name{i}) && ischar(value.(this.name{i}))
            this.namelabel{i} = value.(this.name{i});
         end
      end

   case {'ycomment','ycomments','xcomment','xcomments','ecomment','ecomments','pcomment','pcomments'}
      index = find(attribute(1) == 'yxep');
      this.namelabel(this.nametype == index) = value;

   otherwise
      unrecognized{end+1} = varargin{i};

   end

end

if ~isempty(unrecognized)
   error('Unrecognised attribute: ''%s''.\n',unrecognized{:});
end

end
% End of primary function.