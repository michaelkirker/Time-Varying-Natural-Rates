%% TIMEVARYING_MODEL.MOD
% This is an IRIS Toolbox model file. It gives the equations of the
% economic model of time-varying natural/neutral rates.


%=========================================================================%
!variables:transition
%=========================================================================%


% Domestic Economy Variables
%-------------------------------------------------------------------------%
'Log of domestic output (level)'            y;
'Domesitc output gap'                       y_gap;
'Domestic real interest rate gap'           r_gap;
'Domestic inflation (annualised)'           infl;
'Domestic inflation (annual)'               infl_ann;
'Domestic (nominal) interest rate'          i;


% Domestic Trends
%-------------------------------------------------------------------------%
'Domestic potential output'                 y_trend;
'Domestic growth in potential output'       g;
'Domestic natural real rate'                r_trend;
'Domestic annualized inflation target'      infl_trend;
'Domestic annual inflation target'          infl_ann_trend;
'Domestic real interest rate'               r;
'Natuarl rate of nominal interest'          i_trend;


% Exchange Rate
%-------------------------------------------------------------------------%
'Real exchange rate gap'                    z_gap;
'Log of the real exchange rate'             z;

'Equilbrium risk premium'                   rho_star;
'Log of the natural real exchange rate'     z_trend;


% Foreign Economy
%-------------------------------------------------------------------------%
'Foreign output gap'                        y_gap_US;
'Foreign real interest rate'                r_gap_US;
'Foreign interest rate'                     i_gap_US;

'Foreign infl (annualised)'                 infl_US;
'Foreign infl (annual)'                     infl_ann_US;
'Foreign natural real rate'                 r_US;


%=========================================================================%
!variables:residual
%=========================================================================%


% Domestic Economy
%-------------------------------------------------------------------------%
'Domestic output shock'                     e_y_gap,
'Domestic infl shock'                       e_infl,
'Domestic interest rate shock'              e_i,

'Shock to trend real interest rate'         e_r,
'Shock to inflation target'                 e_targ,
'Shock to potential output growth rate'     e_g,


% Exchange Rate
%-------------------------------------------------------------------------%
'Shock to the risk premium/real exchange rate'      e_z,
'Shock to trend real exchange rate'                 e_ztrend,


% Foreign Economy
%-------------------------------------------------------------------------%
'Foreign output shock'                      e_y_gap_US,
'Foreign infl shock'                        e_infl_US,
'Foreign interest rate shock'               e_r_US,


%=========================================================================%
!parameters
%=========================================================================%


% Domestic Economy
%-------------------------------------------------------------------------%
'Weight on lag in the IS curve'                         beta_lag;
'Effect of real int rate gap on output gap'             beta_r;
'Effect of real exch rate gap on output gap'            beta_z;
'Effect of foreign output gap on output gap'            beta_yUS;

'Weight on lag in the Phillips curve'                   alpha_lag;
'Effect of the output gap on infl'                      alpha_ygap;
'Effect of growth in the real exch rate on infl'        alpha_z;

'Interest rate smoothing parameter'                     gamma_lag;
'Monetary policys responsiveness to infl gap'           gamma_pi;
'Monetary policys responsiveness to output gap'         gamma_ygap;


% Exchange Rate
%-------------------------------------------------------------------------%
'Porportion of rational agents forming expectation in the UIP'  delta_z;


% Foreign Economy
%-------------------------------------------------------------------------%
'Weighting on lag in the IS curve (US)'                 beta_lagUS;
'Effect of real int rate gap on output gap (US)'        beta_rUS;

'Weight on lag in the Phillips curve (US)'              alpha_lagUS;
'Effect of the output gap on infl (US)'                 alpha_ygapUS;

'Interest rate smoothing parameter (US)'                gamma_lagUS;
'Monetary policys responsiveness to infl gap (US)'      gamma_inflUS;
'Monetary policys responsiveness to out gap'            gamma_ygapUS;



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
!equations:transition
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%=========================================================================%
% DOMESTIC ECONOMY
%=========================================================================%

% Domestic IS relationship
y_gap = ( 1 - beta_lag ) * y_gap{+1} + beta_lag * y_gap{-1} - beta_r * r_gap{-1} - beta_z * z_gap{-1} + beta_yUS * y_gap_US + e_y_gap;

% Domestic Phillips curve
infl = ( 1 - alpha_lag ) * infl{+1} + alpha_lag * infl{-1} + alpha_ygap * y_gap{-1} - alpha_z * ( z - z{-1} ) + e_infl;

% Domestic Monetary policy rule
i = gamma_lag * i{-1} + ( 1 - gamma_lag ) * ( i_trend + gamma_pi * ( infl_ann{+4} - infl_ann_trend{+4} ) + gamma_ygap * y_gap ) + e_i;

% Trend nominal exchange rate identity
i_trend = r_trend + infl_trend{+1};



%--------------------------------------------------------------------------
% Domestic economy identities, steady state, and equilibrium equations

% Definition of annualized growth rate of potential oputput
400*(y_trend - y_trend{-1}) = g ;

% Growth rate process - Random Walk
g = g{-1} + e_g;


% Output gap identity
y_gap = 100*(y - y_trend);

% infl target process - Random Walk
infl_trend = infl_trend{-1} + e_targ;

% Natural real rate process - Random Walk
r_trend = r_trend{-1} + e_r;

% Annual inflation identity
infl_ann = ( infl + infl{-1} + infl{-2} + infl{-3} ) / 4;

% Trend annual inflation identity
infl_ann_trend = ( infl_trend + infl_trend{-1} + infl_trend{-2} + infl_trend{-3} ) / 4;

% Real interest rate gap identity
r_gap = r - r_trend;

% Real interest rate identity
r = i - infl{+1};


%=========================================================================%
% EXCHANGE RATE
%=========================================================================%
% Modified UIP condition
z = delta_z * z{+1} + ( 1 - delta_z ) * z{-1} + ( r - r_gap_US + rho_star ) / 4 + e_z;

% Natural real exchange rate process - Random Walk
z_trend = z_trend{-1} + e_ztrend;

% Equilibrium risk premium identity
rho_star = 4 * ( z_trend - delta_z * z_trend{+1} - ( 1 - delta_z ) * z_trend{-1} ) - ( r_trend - r_US );

% Real exchange rate gap identity
z_gap = z - z_trend;


%=========================================================================%
% FOREIGN ECONOMY
%=========================================================================%

% Foreign IS relationship
y_gap_US = ( 1 - beta_lagUS ) * y_gap_US{+1} + beta_lagUS * y_gap_US{-1} - beta_rUS * r_gap_US{-1} + e_y_gap_US;

% Foreign Phillips curve
infl_US = ( 1 - alpha_lagUS ) * infl_US{+1} + alpha_lagUS * infl_US{-1} + alpha_ygapUS * y_gap_US{-1} + e_infl_US;

% Foreign Monetary policy rule
i_gap_US = gamma_lagUS * i_gap_US{-1} + ( 1 - gamma_lagUS ) * ( gamma_inflUS * infl_ann_US{+4}  + gamma_ygapUS * y_gap_US ) + e_r_US;

% Real interest rate identity
r_gap_US = i_gap_US - infl_US{+1};

% Annual infl identity
infl_ann_US = ( infl_US + infl_US{-1} + infl_US{-2} + infl_US{-3} ) / 4;

% Real interest rate (data has been HP filtered).
r_US = 0;



%=========================================================================%
!variables:measurement
%=========================================================================%
% underscore at the end of the variable is used to denote the measurement
% variables
y_
infl_
i_

z_

y_gap_US_
infl_US_
i_US_


%=========================================================================%
!equations:measurement
%=========================================================================%

y_          = y;
infl_       = infl;
i_          = i;

z_          = z;

y_gap_US_   = y_gap_US;
infl_US_    = infl_US;
i_US_       = i_gap_US;