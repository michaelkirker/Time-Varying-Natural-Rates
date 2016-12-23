function [x_tnd, x_gap] = hp(x, lambda)

x = x(:);

x_tnd  = NaN * ones(size(x));
x_gap = NaN * ones(size(x));

u = find(~isnan(x));
if length(u) < 3
  return
else
  sample = u(1):u(end);
  samplelen = length(sample);
end

x_ = x(sample);
    
vx = zeros([samplelen-2, 1]);
vx = x_(1:end-2) - 2*x_(2:end-1) + x_(3:end);
mh = zeros([samplelen+2, 1]);

T = zeros([samplelen-2, 1]);
T(1:3) = [6*lambda+1, -4*lambda, lambda];
T = toeplitz(T);

mh(3:end-2) = T \ vx;

tmp = lambda*(mh(1:end-2) - 2*mh(2:end-1) + mh(3:end));

x_tnd(sample)  = x_ - tmp;
x_gap(sample) = tmp;

return
