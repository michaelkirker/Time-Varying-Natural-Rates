function [I,freq,delta] = fourierdata_(this,data,options)

[ny,nper] = size(data);
data = data(~options.exclude,:);
fdata = fft(data'); 
freq = 2*pi*(0 : nper-1)/nper;
N = 1 + floor(nper/2);
freq = freq(1:N);

% Kronecker delta.
delta = ones([1,N]);
if mod(nper,2) == 0
   delta(2:end-1) = 2;
else
   delta(2:end) = 2;
end

% Sample SGF.
I = zeros([ny,ny,N]);
for i = 1 : N
  I(:,:,i) = fdata(i,:)'*fdata(i,:);
end

% Do not divide by 2*pi
% we skip mutliplying by 2*pi in L1.
I = I/nper;

end