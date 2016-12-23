function mcmc_diagnostic(x2)
% 
% See S. Brooks and Gelman [1998, Journal ]
%

nblck = size(x2,3);
npar  = size(x2,2);
nruns = size(x2,1);

origin = 1000;
step_size = 100;

det_W = zeros(nruns,1);
det_B = zeros(nruns,1);
det_V = zeros(nruns,1);
R     = zeros(nruns,1);
ligne = 0;

for iter = origin:step_size:nruns;
    ligne = ligne + 1; 
    W = zeros(npar,npar);
    B = zeros(npar,npar);
    linea = ceil(0.5*iter);
    n = iter-linea+1;
    muB = mean(mean(x2(linea:iter,:,:),3),1)';  
    for j = 1:nblck;
        muW  = mean(x2(linea:iter,:,j))';
        B = B + (muW-muB)*(muW-muB)';
        for t = linea:iter;
            W = W + (x2(t,:,j)'-muW)*(x2(t,:,j)-muW');     
        end;    
    end;
    W = inv(nblck*(n-1))*W;
    B = n*inv(nblck-1)*B;
    V = inv(n)*(n-1)*W + (1+inv(nblck))*B/n;
    det_W(ligne,1) = det(W);
    det_B(ligne,1) = det(B);
    det_V(ligne,1) = det(V); 
    lambda = max(eig(inv(n*W)*B));
    R(ligne,1) = (n-1)/n + lambda*(nblck+1)/nblck;
end;    

det_W = det_W(1:ligne,1);
det_V = det_V(1:ligne,1);
R     = R(1:ligne,1);

figure('Name','Multivariate convergence diagnostics, Brooks and Gelman (1998)');
subplot(2,1,1);
title('R-statistic (below red line \Rightarrow converged, see Koop 2003)','FontSize',11)
hold on;
plot(origin:step_size:nruns,R,'-k','linewidth',2);
plot(origin:step_size:nruns,repmat(1.2,1,length(origin:step_size:nruns)),'r','linewidth',1.5);
hold off;
subplot(2,1,2);
plot(origin:step_size:nruns,det_W,'--r','linewidth',2);
hold on;
plot(origin:step_size:nruns,det_V,'--b','linewidth',2);
hold off;
title('det(W) and det(V) (Convergence in lines \Rightarrow converged)','FontSize',11);

