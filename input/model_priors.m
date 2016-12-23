function p=model_priors
% Prior specification for each parameter: prior.(parameter)=[pshape,p1,p2];
% where:
% pshape = prior distribution
% p1     = 1st argument of distribution (usually mean)
% p2     = 2nd argument of distribution (usually stdd)
% p3     = lower bound [OPTIONAL]
% p4     = upper bound [OPTIONAL]
%
%--------------------
%
% pshape takes one of the following values:
%         1 is BETA(mean,stdd)
%         2 is GAMMA(mean,stdd)
%         3 is NORMAL(mean,stdd)
%         4 is INVGAMMA(mean,stdd) % converted to IG(s,nu) further down
%         5 is UNIFORM (lower,upper)
%--------------------- 
% Output: p.pshape, p.p1, p.p2, p.p3, p.p4



prior=struct();

% DOMESTIC ECONOMY

   prior.beta_lag   = [1,0.4,0.15];
   prior.beta_r		= [2,0.1,0.05];
   prior.beta_z     = [2,0.01,0.005];
   prior.beta_yUS   = [2,0.05,0.015];
    
   prior.alpha_lag  = [1,0.5,0.15];
   prior.alpha_ygap	= [2,0.1,0.035];
   prior.alpha_z    = [2,0.075,0.05];

   prior.gamma_lag 	= [1, 0.7, 0.2];
   prior.gamma_pi 	= [2, 2, 0.5];
   prior.gamma_ygap = [2, 1, 0.3];
   

% EXCHANGE RATE

    prior.delta_z = [1,0.75,0.15];
	

% FOREIGN ECONOMY
   prior.beta_lagUS	= [1,0.4,0.15];
   prior.beta_rUS   = [2,0.1,0.05];
    
   prior.alpha_lagUS   = [1,0.5,0.15];
   prior.alpha_ygapUS	= [2,0.1,0.035];
   

   prior.gamma_lagUS 	= [1, 0.7, 0.2];
   prior.gamma_inflUS 	= [2, 1.75, 0.5];
   prior.gamma_ygapUS 	= [2, 1, 0.3];
   


% MODEL SHOCKS

    prior.std_e_y_gap 	= [4,0.5,Inf];
    prior.std_e_infl 	= [4,0.5,Inf];
    prior.std_e_i 		= [4,0.5,Inf];
    
	prior.std_e_g 		= [4,0.1,Inf];
	prior.std_e_targ 	= [4,0.15,Inf];
	prior.std_e_r 		= [4,0.2,Inf];

	prior.std_e_z 		= [4,2,Inf];		
	prior.std_e_ztrend 	= [4,1,Inf];
	
    prior.std_e_y_gap_US 	= [4,0.5,Inf];
    prior.std_e_infl_US 	= [4,0.5,Inf];
    prior.std_e_r_US 		= [4,0.5,Inf];
	
	
    

	
   
    

  
    
    

        
%% Loading p and determining bounds for priors
% This section translates the priors into a format the estimation code can
% understand.
p.name = fieldnames(prior);


for i=1:length(p.name)
    p.pshape(i) =prior.(p.name{i})(1);
    p.p1(i)     =prior.(p.name{i})(2);
    p.p2(i)     =prior.(p.name{i})(3);
    if p.pshape(i)==1
        p.p3(i)     = 0;
        p.p4(i)     = 1;
    elseif p.pshape(i)==2
        p.p3(i)     = 0;
        p.p4(i)     = Inf;
    elseif p.pshape(i)==3
        p.p3(i)     = -Inf;
        p.p4(i)     = Inf;
    elseif p.pshape(i)==4
        [p.p1(i),p.p2(i)] = inverse_gamma_specification(p.p1(i),p.p2(i),1);
        p.p3(i)     = 0;
        p.p4(i)     = Inf;
    elseif p.pshape(i)==5
        p.p3(i)     = p.p1(i);
        p.p4(i)     = p.p2(i);
    end;
end;