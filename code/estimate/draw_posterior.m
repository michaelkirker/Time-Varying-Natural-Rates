function [pdens,ffp] = draw_posterior(Theta, optimal)

% This function produces plot of the posterior and prior density
% Needs: mh_optimal_bandwidth.m, kernel_density_estimate.m

nn=length(Theta);
kk='gaussian';
[draws npara] = size(Theta);

%%  Calculates the optimal bandwidth parameter of a kernel estimator
%%  used to estimate a posterior univariate density from realisations of a
%%  Metropolis-Hastings algorithm.
%%
%%  * M. Skold and G.O. Roberts [2003], "Density estimation for the Metropolis-Hastings algorithm".
%%  * Silverman [1986], "Density estimation for statistics and data analysis".
%%
%%  data            :: a vector with n elements.
%%  bandwidth       :: a scalar equal to 0,-1 or -2. For a value different from 0,-1 or -2 the
%%                     function will return optimal_bandwidth = bandwidth.
%%  kernel_function :: 'gaussian','uniform','triangle','epanechnikov',
%%                     'quartic','triweight','cosinus'.
%%  hh              :: returns optimal bandwidth
%--------------------------------------------------------------------------
if optimal==0;
    bb=0;
    display('Rule of thumb bandwidth parameter');
    %  Rule of thumb bandwidth parameter (Silverman [1986] corrected by
    %  Skold and Roberts [2003] for Metropolis-Hastings).
elseif optimal==-1;
    bb=-1;
    display('Plug-in estimation of the optimal bandwidth');
    % Adaptation of the Sheather and Jones [1991] plug-in estimation of the optimal bandwidth
    % parameter for metropolis hastings algorithm.
elseif optimal==-2;
    bb=-2;
    display('Bump killing to smooth long rejecting periods');
    % Bump killing... We construct local bandwith parameters in order to remove
    % spurious bumps introduced by long rejecting periods.
elseif  optimal>0;
    bb=optimal;
    display('User specified');
    % User specified.
end

%Posterior bandwidth:
obandp=[];
i=1;
while i<=npara;
    hh=mh_optimal_bandwidth(Theta(:,i),nn,bb,kk);
    obandp=[obandp; hh];
    i=i+1;
end

%%  Estimating a continuous density. A kernel density
%%  estimator is used (see Silverman [1986]).
%%
%%  * Silverman [1986], "Density estimation for statistics and data analysis".
%%
%%  The code is adapted from DYNARE TOOLBOX.

grid=2^9;
% Posterior Density:
%==========================================================================
pdens=[]; ffp=[];
i=1;
while i<=npara;
    [pden f]=kernel_density_estimate(Theta(:,i),grid,obandp(i),kk);
    pdens=[pdens; pden'];
    ffp=[ffp; f'];
    i=i+1;
end

pdens=pdens';
ffp=ffp';
ind=find(pdens<0);
pdens(ind)=0;