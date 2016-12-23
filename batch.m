%% TIME-VARYING NATURAL RATES MODEL
%
% This batch file demonstrates how to (1) process the data; (2) Estimate
% the model; and (3) Plot some of the results of the estimation.
%
% This code is designed to run in IRIS Toolbox version 7.20090626.



%% Housekeeping

close all;
clear;
home;
restoredefaultpath;

currDir = cd;
addpath(genpath([currDir '/code']));

irisstartup; % Load the IRIS toolbox

inputDir = [currDir '/input'];
tempDir = [currDir '/temp'];
outputDir = [currDir '/output'];

addpath(inputDir);

%% User input
% These settings are used by various parts of the code below

model_file_name = 'timevarying_model.mod';


% Set dates based on the data being used
startdate = qq(1992,1); % Start of historical data
enddate   = qq(2008,1); % End of historical data (today)


% Decide which parts of the code you would like to run:
% 
% If true, the batch file will run that part of the code. Each part can be
% run independently given that the previous parts have been previously run
% at some point in this past. E.g. it is possible to replot the result
% graphs given that an estimated model file already exists. You do not need
% to re-estimate the model again
info = struct();
info.read_in_data = true; % Read in data from spreadsheet 
info.estimate_model = true; % Estimate the model using Bayesian estimation
info.plot_results = true; % Plot graphs showing estimation outcome


% Settings related to the Bayesian estimation

draws = 10000; %Number of MCMC draws    [SET LOW-ISH FOR DEMO PURPOSES]
burn  = 0.5; %Proportion of draws to be burnt
scale = 0.5; %Scale of MCMC draws (higher = reduces acception rate -- should between 0.20 and 0.50)
prange= 0.9; %Probability range for posterior estimates
dates = (startdate+1):enddate; % Estimation sample
bayes_name = 'bayesian_estimates.mat';  %Name of file for saving bayesian estimates and priors
mode_name = 'model@posterior_mode.mat'; % Name of file for saving the model calibrated at posterior mode
post_name = 'model@posterior_mean.mat'; % Name of file for saving the model calibrated at posterior mean
prior_name = 'priors.mat';              % Name of file to store priors in
start_name = 'start_values.mat';        % Name of files to store parameter start values in (values for starting the estimation at)

% The estimation code will use MLE to find the parameter values to start
% the Bayesian estimation from, and then proceed to do the Bayesian draws
% from there.
%
% The options below allow the user to tell the code to start the estimation
% from a previous starting value and/or previous Bayesian estimation chain.
% This can help speed up the estimation process if you are simply looking
% to make more draws.

old_start  = {}; %File name containing start values (e.g 'start_values.mat'): empty => estimate new start values
old_draws  = {}; %File name containing old draws that will be added to (e.g 'bayesian_estimates.mat'): empty=> start new chain







%% Process data input
%
% Read in the raw data, and transform as necessary for the estimation
% process.

if info.read_in_data
    
    % Get raw data for spreadsheet.
    raw_dat_mat = xlsread([inputDir '\raw_data.xlsx']);
    
    
    % Convert raw data matrix into IRIS timeseries.
    %---------------------------------------------------------------------%
    rawdat = struct(); % Matlab structure to hold the time series of the raw data
    
    rawdat.ngdpp_z = tseries(startdate:enddate,raw_dat_mat(:,1),'Real GDP - Total Production GDP (SA)');
    rawdat.r90d = tseries(startdate:enddate,raw_dat_mat(:,2),'3-month bank bill rate at 11am');
    rawdat.pcpis = tseries(startdate:enddate,raw_dat_mat(:,3),'CPI - splice of PCPII to 99q2, PCPI from 99q3');
    rawdat.iusq_z = tseries(startdate:enddate,raw_dat_mat(:,4),'US,  GDP  AT CONSTANT PRICES (seasonally adjusted)');
    rawdat.rus90d = tseries(startdate:enddate,raw_dat_mat(:,5),'United States 3-month bank bill rate');
    rawdat.iuspcco = tseries(startdate:enddate,raw_dat_mat(:,6),'US, CORE CPI - EXCLUDES FOOD AND ENERGY (nadj)');
    rawdat.rusd = tseries(startdate:enddate,raw_dat_mat(:,7),'NZD/USD Exchange Rate ( average 11am)');
    
    
    
    % Transform raw data for the model estimation
    %----------------------------------------------------------------------%
    % Transform the raw data to match the observable variables of the model
    
    estdat = struct(); % Store data for estimation in this structure
    
    % NZ variables
    estdat.y_ = log(rawdat.ngdpp_z); % Log of real GDP
    estdat.i_ = rawdat.r90d; % 90-day interest rate
    estdat.infl_ = pct(rawdat.pcpis,-1)*4; % Annualized QPC inflation
    
    % Foreign variables (filtered with HP filter)
    estdat.y_gap_US_ = hpgap(log(rawdat.iusq_z)*100);
    estdat.i_gap_US_ = hpgap(rawdat.rus90d);
    estdat.infl_gap_US_ = hpgap(pct(rawdat.iuspcco,-1)*4);
    
    % Real exchange rate
    % Normalize both CPI indicies first
    CPInz = rawdat.pcpis/rawdat.pcpis(startdate);
    CPIus = rawdat.iuspcco/rawdat.iuspcco(startdate);
    
    estdat.z_ = 100*( log(rawdat.rusd) + log(CPInz) - log(CPIus) );    % compute log of real exchange rate (up=appeciation)
    
    % Save data into a .mat file
    savestruct([tempDir '\estimation_data.mat'], estdat);
    
    
    
end



%% Create initial model object
% Read in the model equations (timevarying_model.mod) and create an IRIS
% model object. We also apply an arbitrary parameterizationto the model.


P = struct(); % Structure to store our arbitrary parameterization of the model


% DOMESTIC ECONOMY

% IS relationship
P.beta_lag = 0.5;
P.beta_r = 0.1;
P.beta_z = 0.1;
P.beta_yUS = 0.1;

% Phillips curve
P.alpha_lag = 0.5;
P.alpha_ygap =0.1;
P.alpha_z = 0.1;

% Monetary policy rule
P.gamma_lag = 0.7;
P.gamma_pi = 2;
P.gamma_ygap = 1.2;


% EXCHANGE RATE
P.delta_z = 0.5;

% FOREIGN ECONOMY
% IS relationship
P.beta_lagUS = 0.5;
P.beta_rUS =0.1;

% Phillips curve
P.alpha_lagUS = 0.5;
P.alpha_ygapUS = 0.1;

% Monetary policy rule
P.gamma_lagUS = 0.7;
P.gamma_inflUS = 1.5;
P.gamma_ygapUS = 1.2;


% STANDARD ERRORS

% Domestic Economy
P.std_e_y_gap = 1;
P.std_e_infl = 1;
P.std_e_i = 1;

P.std_e_g = 1;
P.std_e_targ = 1;
P.std_e_r = 1;

% Exchange rate
P.std_e_z = 1;
P.std_e_ztrend = 1;

% Foreign economy
P.std_e_y_gap_US = 1;
P.std_e_infl_US = 1;
P.std_e_r_US = 1;


% Create IRIS model object
m=model([ inputDir '\' model_file_name],'assign',P, 'linear',true);

% Solve for the SS of the model given the parameters
m = solve(m);

% Save model object down
savestruct([ tempDir '\model@timevarying_model.mat'],m);



%% Bayesian estimation of model
% This section of the code carries out the Bayesian estimation of the
% model.

if info.estimate_model
    
    
    % Loading data and model
    m = loadstruct([ tempDir '\model@timevarying_model.mat']);
    d = loadstruct([tempDir '\estimation_data.mat']);
    
    
    deviation='true'; % Model is in deviation from S.S.
    
    
    if isempty(old_draws) % If we are not starting the estimation from a previous estimation

        p=model_priors; % Get the priors to use
        
        
        % Plot priors for visual inspection
        %------------------------------------------------------------------
        % Get the user to double check they are happy with the priors
        % before we begin estimation
        [Xprior,fprior]=draw_prior(p);
        
        nfig=ceil(length(p.name)./9);
        nperfig=repmat(9,nfig,1);
        nperfig(end)=length(p.name)-(nfig-1)*9;
        count=1;
        
        for i=1:nfig % each figure
            figure(i);
            for j=1:nperfig(i) % each subplot per figure
                subplot(3,3,j);
                plot(Xprior(:,count),fprior(:,count),'Color','k','LineWidth',2.5);
                title(p.name{count},'Interpreter','None');
                axis tight;
                count=count+1;
            end;
        end;
        
        disp('Check priors are ok. Then push any key to continue:');
        pause;
        close all;
        pause(1);
        %------------------------------------------------------------------
        
        warning('off');
        
        % Start estimation process from the mean of each prior
        for i = 1 : length(p.name)
            m.(p.name{i}) = p.p1(i);
        end;
        
        m = solve(m);
        
        savestruct([tempDir '/' char(prior_name)],p);
        p.range=dates;
        npara=length(p.name);
        Theta=p.p1;
        
        Theta(p.pshape==5) = 1/2*(p.p4(p.pshape==5) - p.p3(p.pshape==5));
        
        if isempty(old_start)
            % Finding the maximum of the posterior via Sims' algorithm
            H0 = 1e-4*eye(npara); crit = 1e-7; nit = 1000;
            [logpost,Theta0,grad,hessian,itct,fcount,retcodehat] = csminwel('postln',Theta,H0,[],crit,nit,m,d,p,deviation);
            logpost=-logpost;
            % Saving estimate of posterior mode
            for i=1:length(p.name)
                m=assign(m,p.name{i},Theta0(i));
            end;
            m=solve(m);
            savestruct([outputDir '/' char(mode_name)],m);
            vv=chol(hessian); %Scale for the MH random draws
            Theta=Theta0;     %Setting start values
            
            %Saving start values
            sv.logpost=logpost;
            sv.vv=vv;
            sv.Theta=Theta;
            savestruct([tempDir '/' char(start_name)],sv);
        else % Starting from previous starting_values
            sv=loadstruct([tempDir '/' char(old_start)]);
            vv=sv.vv;
            Theta=sv.Theta;
            logpost=sv.logpost;
        end;
        Theta_s=zeros(draws,npara); logpost_s=zeros(draws,1);
        acc=0; j=1;
    else
        % Loading previous bayesian estimates and priors
        bayes=loadstruct([tempDir '/' char(old_draws)]);
        for i=1:length(bayes.est_names)
            p.pshape(i)=bayes.prior.(bayes.est_names{i}).pshape;
            p.p1(i)    =bayes.prior.(bayes.est_names{i}).p1;
            p.p2(i)    =bayes.prior.(bayes.est_names{i}).p2;
            p.p3(i)    =bayes.prior.(bayes.est_names{i}).p3;
            p.p4(i)    =bayes.prior.(bayes.est_names{i}).p4;
            Theta_s(:,i)=bayes.post.(bayes.est_names{i});
            Theta_all(:,i)=bayes.post_noburn.(bayes.est_names{i});
        end;
        p.name=bayes.est_names;
        npara=length(p.name);
        p.range=dates;
        
        vv=bayes.vv;                  %Scale for the MH random draws
        Theta=Theta_all(end,:);       %Setting start values
        logpost_s=bayes.logpost;
        logpost = logpost_s(end);
        draws_old = size(Theta_all,1); %Draws to be added to
        Theta_s=[Theta_all;zeros(draws,length(p.name))];
        logpost_s=[logpost_s;zeros(draws,1)];
        draws=draws_old+draws;       %Total draws (old+new)
        acc=bayes.accept*draws_old; % Old number accepted
        j=draws_old+1;
    end;
    
    % MCMC simulations
    %-----------------
    hh   = waitbar(0,'Please wait... Metropolis-Hastings...');
    set(hh,'Name','Metropolis-Hastings, please wait')
    while j<=draws
        newTheta = Theta + scale*randn(1,npara)*vv;
        

        newlogpost=-postln(newTheta,m,d,p,deviation);
        
       
        r=min([1 exp(newlogpost-logpost)]);
        if rand<=r
            logpost=newlogpost;
            Theta=newTheta;
            acc=acc+1;
        end
        

        Theta_s(j,:)=Theta;
        logpost_s(j)=logpost;
        prtfrc = j/draws;
        accept=acc/j;
        j=j+1;
        waitbar(prtfrc,hh,sprintf('%f done, accept rate %f',prtfrc,accept));
    end
    close(hh);
    
    % Burn
    %-----
    draws=size(Theta_s,1);
    Theta_all=Theta_s;
    logpost_all=logpost_s;
    
    Theta_s=Theta_s(round(burn*draws)+1:end,:);
    logpost_s=logpost_s(round(burn*draws)+1:end);
    
    % Computing statistics
    %---------------------
    
    for i=1:length(p.name)
        %Posterior
        e.post.(p.name{i}) = Theta_s(:,i);
        e.post_noburn.(p.name{i}) = Theta_all(:,i);
        e.post_mean.(p.name{i})=mean(Theta_s(:,i));
        e.post_stdev.(p.name{i})=std(Theta_s(:,i));
        e.post_range.(p.name{i})=hpd(Theta_s(:,i),prange);
        m=assign(m,p.name{i},mean(Theta_s(:,i)));
        %Prior
        e.prior.(p.name{i}).pshape = p.pshape(i);
        e.prior.(p.name{i}).p1 = p.p1(i);
        e.prior.(p.name{i}).p2 = p.p2(i);
        e.prior.(p.name{i}).p3 = p.p3(i);
        e.prior.(p.name{i}).p4 = p.p4(i);
    end;
    
    e.density   = marginal_density(Theta_s,logpost_s);
    e.logpost   = logpost_all;
    e.accept    = accept;
    e.est_names = p.name;
    e.vv        = vv;
    e.burn      = burn;
    e.mode_name = mode_name;
    e.mean_name = post_name;
    e.start_name= start_name;
    
    % Saving results
    %---------------
    m=solve(m);
    savestruct([outputDir '\' char(post_name)],m);
    savestruct([outputDir '\' char(bayes_name)],e);
    
    disp(' ');
    disp('---------------------');
    disp('Estimation Complete');
    disp(['Acceptance rate: ' num2str(accept)])
    
    
    
    
end % estimation




















%% Plot graphs
% Plot some output from the estimation process. Here we focus on graphing
% the prior vs posterior for each estimated parameter, and also the Kalman
% smoothed estimates for the paths of the natural/neutral rates from the
% estimated model.

if info.plot_results
    
    % Plotting  priors/posteriors/start values
    %-----------------------------------------
    
    p=model_priors; % Get prior distributions
    
    e= loadstruct([tempDir '\' char(bayes_name)]); % Load estimation (for posterior distribution)
    
    % Starting values
    starts = loadstruct([tempDir '\' e.start_name]); 
    Theta0 = starts.Theta;
    
    ndraws = length(e.post.(e.est_names{1}) );
    
    Theta_s = NaN( ndraws, length(e.est_names));
    for ii = 1:length(e.est_names)
        Theta_s(:,ii) = e.post.(e.est_names{ii});
    end
    
    
    [prior,fprior]=draw_prior(p); % Get coordinates to plot 
    [post,fpost]=draw_posterior(Theta_s,0); % Get coordinates to plot 
    
    % Make graphs
    nfig=ceil(length(p.name)./9);
    nperfig=repmat(9,nfig,1);
    nperfig(end)=length(p.name)-(nfig-1)*9;
    count=1;
    for i=1:nfig
        figure(i);
        for j=1:nperfig(i)
            subplot(3,3,j);
            hold on;
            plot(post(:,count),fpost(:,count),'k','LineWidth',2.5);
            plot(prior(:,count),fprior(:,count),'Color',[0.6 0.6 0.6],'LineWidth',2);
            top=max([fpost(:,count);fprior(:,count)]);
            plot( [Theta0(:,count) Theta0(:,count)], [0,top], '--g', 'linewidth', 2);
            hold off;
            title(p.name{count},'Interpreter','None');
            axis tight;
            count=count+1;
        end;
        legend({'prior','posterior','Starting value'})
    end;
    
    
    
    
    % Time series graphs
    %-------------------    
    m = loadstruct([outputDir '/' char(post_name)]); % Load model
    data = loadstruct([tempDir '\estimation_data.mat']); % Load raw data
    
    
    range = startdate:enddate;
    [this,smooth,se2,delta,pe,F] = filter(m,data,range); % Filter the model on the data
    
    
    % Graphing settings
    shade=[0.9255 0.8392 0.8392];
    D=1992.125:0.25:2008.125;
    range=qq(1992,1):qq(2008,1);
    
    scalefactor=0.025;
    
    figure
    
    %---------------------------------------------------------------------%
    % NATURAL REAL RATE
    
    subplot(2,2,1)
    hold on
    p3 = patch([D fliplr(D)]',[smooth.mean.r_trend(range)+1.645*smooth.std.r_trend(range);flipud(smooth.mean.r_trend(range)-1.645*smooth.std.r_trend(range))]',shade,'EdgeColor',shade);
    p1 = plot(qq(1992,1):qq(2008,1),smooth.mean.r,'LineWidth',1.5,'color','b');
    p2 = plot(qq(1992,1):qq(2008,1),smooth.mean.r_trend,'LineWidth',1.5,'color','r');
    hold off
    title('Natural real rate of int. (r^{*}_{t})');
    legend1=legend([p1 p2 p3],'\it Real interest rate','\it Natural real rate of int.', '\it 90% CI');
    set(legend1,'FontSize',8,'Position',[0.3542 0.8399 0.1018 0.06156]);
    pos = get(gca,'position');
    set(gca,'position',[pos(1)+scalefactor pos(2) pos(3) pos(4)]);
    
    
    %---------------------------------------------------------------------%
    % INFLATION TARGET GRAPH
    
    subplot(2,2,2)
    midpoint =tseries(range,[1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1	1.5	1.5	1.5	1.5	1.5	1.5	1.5	1.5	1.5	1.5	1.5	1.5	1.5	1.5	1.5	1.5	1.5	1.5	1.5	1.5	1.5	1.5	1.5	2	2	2	2	2	2	2	2	2	2	2	2	2	2	2	2	2	2	2	2	2	2]');
    hold on
    p3 = patch([D fliplr(D)]',[smooth.mean.infl_trend(range)+1.645*smooth.std.infl_trend(range);flipud(smooth.mean.infl_trend(range)-1.645*smooth.std.infl_trend(range))]',shade,'EdgeColor',shade);
    plot(midpoint,'LineWidth',1.5,'color','k','LineStyle','--');
    p1 = plot(qq(1992,1):qq(2008,1),data.infl_,'LineWidth',1.5,'color','b') ;
    p2 = plot(qq(1992,1):qq(2008,1),smooth.mean.infl_trend,'LineWidth',1.5,'color','r');
    hold off
    title('Inflation target (\pi^{T}_{t})');
    legend1=legend([p1 p2 p3],'\it Annualised inflation', '\it Inflation target', '\it 90% CI', '\it Midpoint target band');
    set(legend1,'FontSize',8,'Position',[0.576 0.8232 0.09643 0.08033]);
    pos = get(gca,'position');
    set(gca,'position',[pos(1)-scalefactor pos(2) pos(3) pos(4)]);
    
    
    %---------------------------------------------------------------------%
    % OUTPUT GAP
    
    subplot(2,2,3);
    hold on
    p3 = patch([D fliplr(D)]',[smooth.mean.y_gap(range)+1.645*smooth.std.y_gap(range);flipud(smooth.mean.y_gap(range)-1.645*smooth.std.y_gap(range))]',shade,'EdgeColor',shade);
    zeroline = tseries(qq(1992,1):qq(2008,1),zeros(65,1));
    plot(zeroline,'color','k');
    p1 = plot(qq(1992,1):qq(2008,1),hpgap((data.y_)*100),'LineWidth',2,'color',[0 0.498 0],'LineStyle',':');
    p2 = plot(qq(1992,1):qq(2008,1),smooth.mean.y_gap,'LineWidth',1.5,'color','r');
    hold off
    title('Output gap (x_{t})');
    legend1=legend([p1 p2 p3],'\it HP output gap','\it Model estimate','\it 90% CI');
    set(legend1,'FontSize',8,'Position',[0.3819 0.157 0.08095 0.08033]);
    pos = get(gca,'position');
    set(gca,'position',[pos(1)+scalefactor pos(2)+scalefactor pos(3) pos(4)]);
    
    
    %---------------------------------------------------------------------%
    % NEUTRAL EXCHANGE RATE
    
    subplot(2,2,4);
    hold on
    p3 = patch([D fliplr(D)]',[exp((smooth.mean.z_trend(range)+1.645*smooth.std.z_trend(range))/100);flipud(exp((smooth.mean.z_trend(range)-1.645*smooth.std.z_trend(range))/100))]',shade,'EdgeColor',shade);
    p1 = plot(startdate:enddate,exp(data.z_/100),'LineWidth',1.5,'color','b','DisplayName','log(Real exchange rate)');
    p2 = plot(startdate:enddate,exp(smooth.mean.z_trend/100),'LineWidth',1.5,'color','r','DisplayName','log(neutral real exch. rate)') ;
    hold off
    title('Neutral real exchange rate (z^*_{t})');
    legend1=legend([p1 p2 p3],'\it Real exchange rate','\it Neutral real exch. rate', '\it 90% CI');
    set(legend1,'FontSize',8,'Position',[0.5762 0.1507 0.1018 0.06156]);
    pos = get(gca,'position');
    set(gca,'position',[pos(1)-scalefactor pos(2)+scalefactor pos(3) pos(4)]);
    
end