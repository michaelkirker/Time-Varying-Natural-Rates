function X = removeSmall(X)

tol = numerical.matrixTolerance(X);
X(abs(X) <= tol) = 0;

end