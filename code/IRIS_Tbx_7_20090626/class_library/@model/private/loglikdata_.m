function [data,range,varargin,outputformat] = loglikdata_(m,data,varargin)
% LOGLIKDATA_  Detect format of input data, fetch observables, and
% determine output data format.

% The IRIS Toolbox 2009/03/25.
% Copyright 2007-2009 Jaromir Benes.

%********************************************************************
%! Function body.

inputformat = dataformat(data);

switch inputformat
case 'array'
   data = permute(data,[2,1,3]);
   range = 1 : size(data,2);
   inputformat = 'dpack';
case 'dbase'
   range = varargin{1};
   varargin(1) = [];
   data = datarequest('y',m,data,range);
case 'dpack'
   range = data{4}(1)+1:data{4}(end);
   data = datarequest('y',m,data,Inf);
otherwise
   error('Unknow input data format.');
end

outputformat = 'auto';
index = find(strcmpi('output',varargin),1);
if ~isempty(index)
   outputformat = varargin{index+1};
   varargin(index:index+1) = [];
end
if strcmpi(outputformat,'auto')
   outputformat = inputformat;
end

end
% End of primary function.