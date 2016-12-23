function density_plot = plot_density( Theta, Prior, names, optimal )

% This function produces plot of the posterior and prior density
% Needs: mh_optimal_bandwidth.m, kernel_density_estimate.m

nn=length(Theta);
mm=length(Prior);
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

%Prior bandwidth:
obandpr=[];
i=1;
while i<=npara;
    hh=mh_optimal_bandwidth(Prior(:,i),mm,bb,kk);
    obandpr=[obandpr; hh];
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
pdens=[];
ffp=[];
i=1;
while i<=npara;
    [pden f]=kernel_density_estimate(Theta(:,i),grid,obandp(i),kk);
    pdens=[pdens; pden'];
    ffp=[ffp; f'];
    i=i+1;
end
% Prior Density:
%==========================================================================
prdens=[];
ffpr=[];
i=1;
while i<=npara;
    [prden f]=kernel_density_estimate(Prior(:,i),grid,obandpr(i),kk);
    prdens=[prdens; prden'];
    ffpr=[ffpr; f'];
    i=i+1;
end


% Plots:
%--------------------------------------------------------------------------

blocks=round(npara/9);
j=1; k=1;
while j<=blocks;
    i=1;
    figure(j)
    while i<=9;
        subplot(3,3,i);
        if k>size(pdens,2);
            return;
        end;
        plot(pdens(k,:), ffp(k,:) , 'b', 'LineWidth',0.75);
        hold on
        plot(prdens(k,:), ffpr(k,:), 'g', 'LineWidth', 0.5);
        hold off
        title(names{k},'Interpreter','None')
        axis tight;
        i=i+1;
        k=k+1;
    end
    j=j+1;
end;
