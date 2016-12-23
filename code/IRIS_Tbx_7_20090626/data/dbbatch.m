function [dbase,list0,list,flag] = dbbatch(dbase0,namemask,exprmask,varargin)
% <a href="matlab: edit dbbatch.m">DBBATCH</a>  Batch job within database.
%
% Syntax:
%   [d,inlist,outlist] = dbbatch(d,name,expr,...)
% Output arguments:
%   d [ struct ] Output <a href="databases.html">database</a>.
%   inlist [ cellstr ] List of processed series.
%   outlist [ cellstr ] List of newly created/named database entries.
% Required input arguments:
%   d [ struct ] Input <a href="databases.html">database</a>.
%   name [ char ] Name mask for newly created database entries (use '$0', '$1', etc.).
%   expr [ char ] Evaluate this expression to create new database entries.
% <a href="options.html">Optional input arguments:</a>
%  'classfilter' [ char | <a href="default.html">Inf</a> ] Process only database entries of a certain class.
%  'merge' [ <a href="default.html">true</a> | false | struct ] Preserve unprocessed input database entries or entries of a specified database in output database.
%  'namefilter' [ char | <a href="default.html">empty</a> ] Process database entries that match regular expression.
%  'namelist' [ cellstr | <a href="default.html">empty</a> ] List of database entries to be processed.

% The IRIS Toolbox 2009/06/10.
% Copyright (c) 2007-2008 Jaromir Benes.

if ~isstruct(dbase0) || ~ischar(namemask) || ~ischar(exprmask) || ~iscellstr(varargin(1:2:nargin-3))
   error('Incorrect type of input argument(s).');
end

default = {
  'append',true,@islogical,...
  'classfilter',Inf,@(x) (isnumeric(x) && isinf(x)) || ischar(x),...
  'namefilter',Inf,@(x) (isnumeric(x) && isinf(x)) || ischar(x),...
  'namelist',{},@(x) ischar(x) || iscellstr(x),...
  'merge',true,@(x) islogical(x) || isstruct(x),...
};
options = passvalopt(default,varargin{:});

if any(strcmpi(varargin(1:2:end),'append'))
   warning('iris:obsolete','APPEND is an obsolete option. Use MERGE instead.');
   options.merge = options.append;
end

if ischar(options.namelist)
   options.namelist = charlist2cellstr(options.namelist);
end

%********************************************************************
%! Function body.

% when called P = dbase(P,...) within a function, P is locked as a variable under construction
% crate a temporary database IRIS_TEMP_DBASE in caller's workspace
assignin('caller','IRIS_TEMP_DBASE__',dbase0);
exprmask = regexprep(exprmask,sprintf('\\<%s\\>',inputname(1)),'IRIS_TEMP_DBASE__');

[list0,list,expr] = dbquery(dbase0,namemask,exprmask,options.classfilter,options.namefilter,options.namelist);
expr = strrep(expr,'"','''');

flag = true;
if isstruct(options.merge)
   dbase = options.merge;
elseif options.merge
   dbase = dbase0;
else
   dbase = struct();
end

errorlist = {};
for i = 1 : length(list0)
   try
      warning('');
      value = evalin('caller',expr{i});
      dbase.(list{i}) = value;
      msg = lastwarn();
      if ~isempty(msg)
         tmpexpr = strrep(expr{i},'IRIS_TEMP_DBASE__',inputname(1));
         fprintf(1,'The above warning occurred when DBBATCH attempted to evaluate %s.\n\n',tmpexpr);
      end
   catch
      errorlist(end+(1:2)) = {expr{i},geterrormsg()};
   end
end

evalin('caller','clear IRIS_TEMP_DBASE__');

if ~isempty(errorlist)
   errorlist = strrep(errorlist,'IRIS_TEMP_DBASE__',inputname(1));
   flag = false;
   warning('\nWhen evaluating DBBATCH expression "%s" Matlab produced the following error:\n\t%s',errorlist{:});
end

end
% End of primary function.