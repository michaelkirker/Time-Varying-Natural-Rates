%function mode_check_IRIS(x,fval,hessian,gend,data,lb,ub)

% function mode_check(x,fval,hessian,gend,data,lb,ub)
% Checks the maximum likelihood mode 
% 
% INPUTS
%    x:       mode
%    fval:    value at the maximum likelihood mode
%    hessian: matrix of second order partial derivatives
%    gend:    scalar specifying the number of observations
%    data:    matrix of data
%    lb:      lower bound
%    ub:      upper bound
%
% OUTPUTS
%    none
%        
% SPECIAL REQUIREMENTS
%    none

% Copyright (C) 2003-2008 Dynare Team
%
% This file is part of Dynare.
%
% Dynare is free software: you can redistribute it and/or modify
% it under the terms of the GNU General Public License as published by
% the Free Software Foundation, either version 3 of the License, or
% (at your option) any later version.
%
% Dynare is distributed in the hope that it will be useful,
% but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
% GNU General Public License for more details.
%
% You should have received a copy of the GNU General Public License
% along with Dynare.  If not, see <http://www.gnu.org/licenses/>.

%global bayestopt_ M_ options_

clc
close all
clear all


sv=load('..\start_values.mat');
x=sv.Theta;
hessian=sv.vv;
fval=sv.logpost;





%%
bayes_name  = '..\bayesian_estimates.mat';
b           = loadstruct(bayes_name); 
m = loadstruct('..\model@posterior_mode.mat');
est_paras  = fieldnames(b.post);                % all parameters and shocks estimated by the model

dates = qq(1992,1):qq(2008,1);

d = loadstruct('..\data@timevarying_model.mat');






%% ub and lb

ub=NaN(length(est_paras),1);
lb=NaN(length(est_paras),1);

for ii = 1:length(est_paras)
shape=b.prior.(est_paras{ii}).pshape;

    switch shape
        case 1 % Beta
            ub(ii)= 0.999;
            lb(ii)= 0.001;
        case 2 % Gamma
            ub(ii)= b.prior.(est_paras{ii}).p1 + 2*(b.prior.(est_paras{ii}).p2);
            lb(ii)= 0.001;
        case 3 % Normal
            ub(ii)= b.prior.(est_paras{ii}).p1 + 2*(b.prior.(est_paras{ii}).p2);
            lb(ii)= b.prior.(est_paras{ii}).p1 - 2*(b.prior.(est_paras{ii}).p2);
        case 4 % Inv Gamma
            ub(ii)= 10;                                                                  % NEED TO FIX THIS LINE UP
            lb(ii)= 0.001;
        case 5 % Uniform
            ub(ii)= b.prior.(est_paras{ii}).p2;
            lb(ii)= b.prior.(est_paras{ii}).p1;
        otherwise
            disp('Error: unknown pshape');
    end;
end;

%% Plot figure


nfig=ceil(length(est_paras)./9);
nperfig=repmat(9,nfig,1);
nperfig(end)=length(est_paras)-(nfig-1)*9;

count=1;

for i=1:nfig;
    figure(i);
    
    for j=1:nperfig(i);
        subplot(3,3,j);
        
        
        
        %
        tmp1 = [lb(count): (ub(count)-lb(count))/10 :ub(count)]';

        
        
        tmp2 = NaN(length(tmp1),1);
        for jj = 1:length(tmp1);
            m1=m;
            m1.(est_paras{count})= tmp1(jj);
            [m1,npaths]=solve(m1);
            
            if npaths ~= 1;
                tmp2(jj)=NaN;
            else
                tmp2(jj) = loglik(m1,d,dates,'deviation',true,'output','dbase');
            end;

            
      
        end

        
        %
        
        
        plot(tmp1,tmp2)
        line([x(count) x(count)],[min(tmp2) max(tmp2)],'Color','r','Linestyle','--');
        
       
        title(est_paras{count},'Interpreter','None');
        axis tight;
        
        count=count+1;
       

        
    end;
    


end;



%%




%%



return



figure

num_fig

fig_length = ceil(length(est_paras)/3);


for ii = 1:length(est_paras)
    subplot(fig_length,3,ii)
    
    
    % plot mode
        
        
        axis square
    
end;


return;

%gend = # of observations;
%data = matrix of data




%    gend:    scalar specifying the number of observations
%    data:    matrix of data
%    lb:      lower bound
%    ub:      upper bound





[s_min,k] = min(diag(hessian))
  
% disp('\nMODE CHECK\n')
% disp(sprintf('Fval obtained by fmincon: %f', fval))
% disp(bayestopt_.name)
% cname = bayestopt_.name{k};
% disp(sprintf('Most negative variance %f for parameter %d (%s = %f)',s_min,k,cname,x(k)))

[nbplt,nr,nc,lr,lc,nstar] = pltorg(length(x));



if nbplt == 1
    hh = figure('Name','Check plots');
    for k=1:length(x)
        subplot(nr,nc,k)
        %[name,texname] = get_the_name(k,TeX);
        xx = x;
        l1 = max(lb(k),0.8*x(k)); % kk -> k
        l2 = min(ub(k),1.2*x(k)); % kk -> k
        z = [l1:(l2-l1)/20:l2];
        y = zeros(length(z),1);
        for i=1:length(z)
            xx(k) = z(i); % kk -> k
            if isempty(strmatch('dsge_prior_weight',M_.param_names))
                y(i) = DsgeLikelihood(xx,gend,data);
            else
                y(i) = DsgeVarLikelihood(xx,gend);
            end
        end
        plot(z,y)
        hold on
        yl=get(gca,'ylim');
        plot([x(k) x(k)],yl,'c','LineWidth', 1);% kk -> k
        title(name,'interpreter','none');
        hold off
        drawnow
    end
    eval(['print -depsc2 ' M_.fname '_CheckPlots' int2str(1) '.eps' ]);
    if options_.nograph, close(hh), end  
       
else
    for plt = 1:nbplt-1
 
        hh = figure('Name','Check plots');
        for k=1:nstar
            subplot(nr,nc,k)
            kk = (plt-1)*nstar+k;
            %[name,texname] = get_the_name(kk,TeX);
            xx = x;
            l1 = max(lb(kk),0.8*x(kk));
            l2 = min(ub(kk),1.2*x(kk));
            z = [l1:(l2-l1)/20:l2];
            y = zeros(length(z),1);
            for i=1:length(z)
                xx(kk) = z(i);
                if isempty(strmatch('dsge_prior_weight',M_.param_names))
                    y(i) = DsgeLikelihood(xx,gend,data);
                else
                    y(i) = DsgeVarLikelihood(xx,gend);
                end                
            end
            plot(z,y);
            hold on
            yl=get(gca,'ylim');
            plot( [x(kk) x(kk)], yl, 'c', 'LineWidth', 1)
            title(name,'interpreter','none')
            hold off
            drawnow
        end    
        eval(['print -depsc2 ' M_.fname '_CheckPlots' int2str(plt) '.eps']);
        if options_.nograph, close(hh), end
        
    end
    hh = figure('Name','Check plots');
    k = 1;

    while (nbplt-1)*nstar+k <= length(x)
        kk = (nbplt-1)*nstar+k;
  
        if lr ~= 0
            subplot(lr,lc,k)
        else
            subplot(nr,nc,k)
        end    
        xx = x;
        l1 = max(lb(kk),0.8*x(kk));
        l2 = min(ub(kk),1.2*x(kk));
        z = [l1:(l2-l1)/20:l2];
        y = zeros(length(z),1);
        for i=1:length(z)
            xx(kk) = z(i);
            if isempty(strmatch('dsge_prior_weight',M_.param_names))
                y(i) = DsgeLikelihood(xx,gend,data);
            else
                y(i) = DsgeVarLikelihood(xx,gend);
            end                
        end
        plot(z,y)
        hold on
        yl=get(gca,'ylim');
        plot( [x(kk) x(kk)], yl, 'c', 'LineWidth', 1)
        title(name,'interpreter','none')
        hold off
        k = k + 1;
        drawnow
    end
    eval(['print -depsc2 ' M_.fname '_CheckPlots' int2str(nbplt) '.eps']);

    if options_.nograph, close(hh), end
end