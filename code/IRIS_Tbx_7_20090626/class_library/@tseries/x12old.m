function xsa = x12(x,range,options)
%
% X12  Census X12-ARIMA seasonal adjustment.
%   XSA = x12(X)
%   XSA = x12(X,RANGE)
%   XSA = x12(X,RANGE,=options=)
%   X: tseries, RANGE: double (range), =options=: cell array, XSA: tseries
%   =options=: 'arima','display', 'method', 'tdays'

if ~isa(x,'tseries') || (nargin > 1 && ~isnumeric(range)) || (nargin > 2 && ~isa(options,'struct') && ~isa(options,'cell'))
  error('Incorrect type of input argument(s).');
end

if nargin < 2
  range = Inf;
end

if nargin < 3
  options = struct;
elseif isa(options,'cell')
  options = struct(options{1:end});
end

default = {
  'method','mult',...
  'tdays',false,...
  'arima','off',...
  'display','off',...
};

for i = 1 : size(default,1)
  if ~isfield(options,default{i,1})
    options.(default{i,1}) = default{i,2};
  end
end

if isa(options.display,'logical')
  if options.display == true
    options.display = 'on';
  elseif options.display == false
    options.display = 'off';
  end
end

if isnumeric(options.method)
  if options.method == 0
    options.method = 'mult';
  elseif options.method == 1
    options.method = 'add';
  end
elseif isa(options.method,'char')
  if strcmp(options.method,'m')
    options.method = 'mult';
  elseif strcmp(options.method,'a')
    options.method = 'add';
  end
end

% -----function X12 body----- %

irisconfig = irisget();

if isempty(irisconfig.x12exepath)
  error('Census X12 procedure not linked. Unable to use tseries/x12 function.');
end

if ~strcmp(options.arima,'off') && isempty(irisconfig.x12mdlpath)
  error('Automodel for Census X12-ARIMA procedure not linked. Unable to use tseries/x12 function with ''arima'' option.');
end

if strcmp(options.display,'on')
  redir = '';
  output = '';
else
  redir = ' >> ';
  output = tempname;
end

if isinf1(range), range = range_(x); end
range = vech(range);

[fName,range,flag] = thisspcfile(x,range,irisconfig,options);

data = [];
if flag
  delete([fName,'.*']);
  error('Unable to create X12 spec file.');
else
  exeLine = [irisconfig.x12exepath,' ',fName,redir,output];
  status = system(exeLine);
  if status ~= 0
    delete([fName,'.*']);
    if exist(output)
      delete(output);
    end
    error('Unable to execute X12 program.');
  end
  [data,flag] = locx12d11(x,fName);
  delete([fName,'.*']);  
  if flag == true
    if exist(output)
      delete(output);
    end
    error('Unable to read X12 output file.');    
  end
end
xsa = tseries(range,data);

if ~isempty(output)
  delete(output);
end

return

  %% -----{local function}-----
  
  function [fName,range,flag] = thisspcfile(x,range,irisconfig,options);
  %% www.census.govt./srd/www/x12a
    
  data = getdata_(x,range);
 
  if any(isnan(data))
    warning('Time series cut appropriately not to contain NaN.');
    aux = find(~isnan(data));
    range = range(aux);
    data = data(aux);
  end
    
  newLine = [char(13),char(10)];
  
  [year,per,freq] = dat2ypf(range(1));
  start = sprintf('%g.%g',round(year),round(per));
  
  fid = fopen('series.spc','r');
  spcCode = transpose(char(fread(fid)));
  fclose(fid);
  
  if strcmp(options.arima,'fcst') || strcmp(options.arima,'both')
    fid = fopen('automdl.spc','r');
    spcCode = [spcCode,newLine,transpose(char(fread(fid)))];
    fclose(fid);
  end

  fid = fopen('x11.spc','r');
  spcCode = [spcCode,newLine,transpose(char(fread(fid)))];
  fclose(fid);

  if options.tdays == true
    fid = fopen('x12tdays.spc','r');
    spcCode = [spcCode,newLine,transpose(char(fread(fid)))];
    fclose(fid);
  end
  
  spcCode = strrep(spcCode,'METHOD',options.method);
  spcCode = strrep(spcCode,'START',start);
  spcCode = strrep(spcCode,'FREQ',sprintf('%i',freq));
  spcCode = strrep(spcCode,'DATA',sprintf(['%.8f',newLine],data));
  spcCode = strrep(spcCode,'AUTOMDLMODE',options.arima);
  spcCode = strrep(spcCode,'AUTOMDLFILE',irisconfig.x12mdlpath);
  
  [aux,fName] = fileparts(tempname);
  fName = [strrep(cd,'\','/'),'/',fName];

  spcName = [fName,'.spc'];
  d11Name = [fName,'.d11'];
  
  flag = false;
  
  fid = fopen(spcName,'w+');
  if fid == -1
    flag = true;
    return
  end
  
  count = fwrite(fid,spcCode,'char');
  if count == 0
    flag = true;
    return
  end
  
  fclose(fid);

  return
  
  %% -----{local function}-----
  
  function [data,flag] = locx12d11(x,fName)

  data = zeros([1,0]);
  flag = false;
  
  fid = fopen([fName,'.d11'],'r');
  
  if fid == -1
    flag = true;
    return
  end

  fgetl(fid);
  aLine = fgetl(fid);
  
  data = fscanf(fid,'%f %f');
  
  fclose(fid);
  
  data = transpose(reshape(data,[2,length(data)/2]));
  data = data(:,2);
  
  return