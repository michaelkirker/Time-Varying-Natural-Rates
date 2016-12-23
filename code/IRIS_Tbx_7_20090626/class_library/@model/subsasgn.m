function this = subsasgn(this,s,b)
% <a href="matlab: edit model/subsasgn">SUBSASGN</a>  Subscripted assignment to model objects.
%
% Syntax:
%   this(index) = another
%   this(index) = []
%   this.name = n
%   this(index).name = n
%   this.name(index) = n
% Output arguments:
%   this [ model ] Model.
% Required input arguments
%   another [ model ] Model whose parameters and steady states will be assigned to this model.
%   name [ char ] Parameter or variable name to be changed.
%   n [ numeric ] New value(s) of the respective parameter or steady state.
%   index [ logical | numeric | empty] Index of parameterisations to be changed.
%
% Nota bene:
%   Syntax (2) is used to delete some parameterisations (and hence to reduce their number).
%   Syntaxes (4) and (5) are equivalent.

% The IRIS Toolbox 2009/04/28.
% Copyright 2007-2009 Jaromir Benes.

if ~ismodel(this) || (~ismodel(b) && ~isempty(b) && ~isnumeric(b))
  error('Incorrect type of input argument(s).');
end

%********************************************************************
%! Function body.

% chksubsref converts
%   this(index).name -> this.name(index)
%   this(index1).name(index2) -> this.name(index1(index2))
% for integer index nd replaces 'end' & ':'
nalt = size(this.assign,3);
s = chksubsref_(s,nalt);

% this(index) = b
% b must be model or empty

if any(strcmp(s(1).type,{'()','{}'}))

  if ~ismodel(b) && ~isempty(b)
    error('Invalid subscripted reference to model object.');
  end

  na = size(this.assign,3);
  aindex = s(1).subs{1};

  % this([]) = b leaves this unchanged
  if isempty(aindex)
    return
  end

  naindex = length(aindex);
  if max(aindex) > na
    % expand the number of parameterisations if max index exceeds the current number
    expand_();
  end

  if ismodel(b) && ~isempty(b)
    % this(index) = b
    % where b is this non-empty model
    nb = size(b.assign,3);
    if nb == 1
      bindex = ones([1,naindex]);
    else
      bindex = 1 : nb;
      if naindex ~= nb && nb > 0
        error('Number of parameterisations on the LHS and RSH of an assignment must be the same.');
      end
    end
    assignmodel_();
  else
    % this(index) = [] or this(index) = b
    % where b is an empty model
    assignempty_();
  end

% this.name = b or this.name(index) = b 
% b must be numeric

elseif strcmp(s(1).type,'.')
 
  if ~isnumeric(b)
    error('Invalid subscripted reference to model object.');
  end

  index1 = strcmp(s(1).subs,this.name);
  if ~any(index1)
    error('Unrecognised variable or parameter name: "%s".',s(1).subs);
  end

  if length(s) > 1
    % this.name(index0 = b
    index2 = s(2).subs{1};
  else
    % another.name = b
    index2 = 1 : length(this);
  end

  this.assign(1,index1,index2) = b;

end
% End of function body.

%********************************************************************
%! Nested function expand_().

   function expand_()
      index = na+1 : max(aindex);
      this.assign(1,:,index) = NaN;
      this.eigval(1,:,index) = NaN;
      this.icondix(1,:,index) = false;
      this.optimal(1,index) = false;
      for i = 1 : length(this.solution)
         s1 = size(this.solution{i},1);
         s2 = size(this.solution{i},2);
         % s1 or s2 can be zero in which case we cannot use (:,:,index)
         this.solution{i}(1:s1,1:s2,index) = NaN;
      end
      for i = 1 : length(this.expand)
         s1 = size(this.expand{i},1);
         s2 = size(this.expand{i},2);
         % s1 or s2 can be zero in which case we cannot use (:,:,index)
         this.expand{i}(1:s1,1:s2,index) = NaN;
      end
   end
% End of nested function expand_().

%********************************************************************
%! Nested function assignmodel_().

   function assignmodel_()
      this.assign(1,:,aindex) = b.assign(1,:,bindex);
      this.eigval(1,:,aindex) = b.eigval(1,:,bindex);
      this.optimal(1,aindex) = b.optimal(1,bindex);
      this.icondix(1,:,aindex) = b.icondix(1,:,bindex);
      for i = 1 : length(this.solution)
         this.solution{i}(:,:,aindex) = b.solution{i}(:,:,bindex);
      end
      for i = 1 : length(this.expand)
         this.expand{i}(:,:,aindex) = b.expand{i}(:,:,bindex);
      end
   end
% End of nested function assignmodel_().

%********************************************************************
%! Nested function assignempty_().

   function assignempty_()
      this.assign(:,:,aindex) = [];
      this.eigval(:,:,aindex) = [];
      this.optimal(:,aindex) = [];
      for i = 1 : length(this.solution)
         s1 = size(this.solution{i},1);
         s2 = size(this.solution{i},2);
         this.solution{i}(1:s1,1:s2,aindex) = [];
      end
      for i = 1 : length(this.expand)
         s1 = size(this.expand{i},1);
         s2 = size(this.expand{i},2);
         this.expand{i}(1:s1,1:s2,aindex) = [];
      end
   end
% End of nested function assignempty_().

end
% End of primary function.