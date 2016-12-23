function [RR,CC] = pdlrestrict_(ny,nk,ng,p,polyorder)
%
% @RVAR/PRIVATE/PDLRESTRICT_  Polynominal distributed lags restriction for reduced-form VAR
%
% IR!S Toolbox November 28, 2005 

% CC*b = hyper
% b = RR*hyper

lags = repmat(vec(0 : p-1),[1,polyorder+1]);
powers = repmat(0 : polyorder,[p,1]);
nconstr = p - polyorder - 1;

RR0 = zeros([ny*ny*p,polyorder+1]);
RR0(1:ny*ny:end,:) = lags.^powers;
CC0 = zeros([p-polyorder-1,ny*ny*p]);
CC0(:,1:ny*ny:end) = transpose(null(transpose(RR0(1:ny*ny:end,:))));

CC = zeros([0,ny*ny*p]);
RR = zeros([ny*ny*p,0]);
for i = 1 : ny*ny
  RR = [RR,[zeros([i-1,polyorder+1]);RR0(1:end-(i-1),:)]];
  CC = [CC;zeros([nconstr,i-1]),CC0(:,1:end-(i-1))];
end
CC = [CC,zeros([size(CC,1),ny*(nk+ng)])];
RR = blkdiag(RR,eye(ny*(nk+ng)));

end