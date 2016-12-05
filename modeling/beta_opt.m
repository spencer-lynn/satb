function beta=beta_opt(model,target_scenario)
% SAtb fn beta_opt(model,target_scenario) -- Calculate environment's optimal beta value given parameters.
% Use this (rather than "beta" output of expt_model) to derive optimal beta value for a scenario.
% - but can use slope (of indiffernce line) from expt_model/compare_params2 instead of this.
% Put that value into expt_sxb.m, to be called when determining distance to LOR.
% 
% Where:
%     model = m-file defining signal parameter model for given experiment.
%     - model output is a struct of scenarios (signal parameter value sets)
%     target_scenario = a scenario w/in the overall model
% 
% (beta-eq itself is: beta=exp(c.*d))
% 
% After Tanner & Swets 1954 (eq 2). See also: 
% - Wiley 1994: eq for S = slope of indifference line.
% - Bradbury & Vehrencamp 1998:432, beta as "operating level".
% = Optimal beta value is same thing as value of the slope of the indifference line.
%     
% Spencer Lynn, spencer.lynn@gmail.com
% 6/19/12

scenarios=eval(model); %returns struct of parameter values for each scenario in expt.
baserate=scenarios.baserate(strmatch(target_scenario,scenarios.names));
h=scenarios.h(strmatch(target_scenario,scenarios.names));
a=scenarios.a(strmatch(target_scenario,scenarios.names));
m=scenarios.m(strmatch(target_scenario,scenarios.names));
j=scenarios.j(strmatch(target_scenario,scenarios.names));

beta = ((1-baserate)/baserate) * ((j-a)/(h-m));

end %fn