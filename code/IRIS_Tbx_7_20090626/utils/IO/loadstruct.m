function x = loadstruct(fname)
% <a href="matlab: edit utils/io/loadstruct">LOADSTRUCT</a>  Load struct-convertible object saved previously by SAVESTRUCT.
%
% Syntax:
%   x = loadstruct(fname)
% Output arguments:
%   x [ model | tseries | VAR ] Object loaded.
% Required input arguments:
%   fname [ char ] File name.

% The IRIS Toolbox 2009/04/09.
% Copyright (c) 2007-2008 Jaromir Benes.

%********************************************************************
%! Function body.

% Load all entries.
% Because keywords are loaded with underscores, fix their names.
list = vech(who('-file',fname));
index = cellfun(@iskeyword,list);
if any(~index)
  x = load('-mat',fname,list{~index});
else
  x = struct();
end
if any(index)
  state = warning('query');
  warning('off','MATLAB:load:loadingKeywordVariable');
  temp = load('-mat',fname,list{index});
  temp = struct2cell(temp);
  for i = find(index)
     x.(list{i}) = temp{i};
  end
  warning(state);
else
  x = load('-mat',fname);
end

if isfield(x,'SAVESTRUCT_CLASS')
   thisClass = x.SAVESTRUCT_CLASS;
   x = rmfield(x,'SAVESTRUCT_CLASS');
else
   % For bkw compatibility only:
   % Convert IRIS_MODEL=true to CLASS='MODEL' etc.
   if isfield(x,'IRIS_MODEL')
      thisClass = 'model';
      x = rmfield(x,'IRIS_MODEL');
   elseif isfield(x,'IRIS_VAR')
      thisClass = 'VAR';
      x = rmfield(x,'IRIS_VAR');
   elseif isfield(x,'IRIS_RVAR')
      thisClass = 'VAR';
      x = rmfield(x,'IRIS_RVAR');
   elseif isfield(x,'IRIS_SVAR')
      thisClass = 'VAR';
      x = rmfield(x,'IRIS_SVAR');
   elseif isfield(x,'IRIS_TSERIES') || (isfield(x,'start') && isfield(x,'data') && isfield(x,'comment'))
      thisClass = 'tseries';
      x = rmfield(x,'IRIS_TSERIES');
   elseif isfield(x,'IRIS_CONTAINER')
      thisClass = 'container';
      x = rmfield(x,'IRIS_CONTAINER');
   else
      thisClass = 'struct';
   end
end

switch thisClass
case 'model'
   % Convert array of occurences to sparse matrix.
   if ~issparse(x.occur)
      x.occur = sparse(x.occur(:,:));
   end
   % Convert symbolic-derivative chars to function handles.
   if isfield(x,'deqtnF')
      for i = 1 : length(x.deqtnF)
         for j = 1 : length(x.deqtnF{i})
            if ischar(x.deqtnF{i}{j}) && ~isempty(x.deqtnF{i}{j})
               x.deqtnF{i}{j} = eval(x.deqtnF{i}{j});
            end
         end
      end
   else
     x.deqtnF = {};
   end
   % Convert full-equation chars to function handles.
   for i = 1 : length(x.eqtnF)
      if ischar(x.eqtnF{i}) && ~isempty(x.eqtnF{i})
         if strcmp(x.eqtnF{i}(1),'@')
            x.eqtnF{i} = eval(x.eqtnF{i});
         else
            if x.eqtntype(i) <= 2
               x.eqtnF{i} = eval(sprintf('@(x,t)%s',x.eqtnF{i}));
            else
               x.eqtnF{i} = eval(sprintf('@(x,t,ttrend)%s',x.eqtnF{i}));
            end
         end
      end
   end
   % Add empty dtrends equations if missing.
   ny = sum(x.nametype == 1);
   if ny > 0 && sum(x.eqtntype == 3) == 0
      x.eqtn(end+(1:ny)) = {''};
      x.eqtnS(end+(1:ny)) = {''};
      x.eqtnF(end+(1:ny)) = {@(x,t,ttrend)0};
      x.eqtnlabel(end+(1:ny)) = {''};
      x.eqtntype(end+(1:ny)) = 3;
      x.occur(end+(1:ny),:) = false;
   end
   % Add empty dynamic links if missing.
   if sum(x.eqtntype == 4) == 0
      nname = sum(x.nametype <= 4);
      x.eqtn(end+(1:nname)) = {''};
      x.eqtnS(end+(1:nname)) = {''};
      x.eqtnF(end+(1:nname)) = {[]};
      x.eqtnlabel(end+(1:nname)) = {''};
      x.eqtntype(end+(1:nname)) = 4;
      x.refresh = [];
   end
   % Add 'optimal' if missing.
   if ~isfield(x,'optimal')
      nalt = size(x.assign,3);
      x.optimal = false([1,nalt]);
   end
   % Create model class object and return.
   x = model(x);

case 'VAR'
   x = VAR(x);

case 'tseries'
   x = tseries(x);

case 'container'
   x = container(x);

otherwise
   
end
% End of primary function.
