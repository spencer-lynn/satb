function scenarios=satb_demo_model
%models for sigbasics2 study as of 1/26/12
% - uses two of the sb1 scenarios, presented in different order than in sb1.
%
%Step 1: code the parameter values for the scenarios
%Step 2: turn on/off any plotting
%
% calls compare_params2.m in SAtoolbox

[myname mypath]=setdir(mfilename); %output files get writtn to same dir as THIS scenairo model file
scenarios=define_scenarios;        %set parameter values
model_checkerr(scenarios)          %parameter value error checking

%% Comment out for data processing rather that param exploration.
plots=define_plots;                %turn plotting on/off
p=compare_params2(scenarios,plots,myname,1); %run the model
disptable(p.measures', scenarios.names, p.key') %disptable is a 3rd party fn.
end %parameter set def'n


function scenarios=define_scenarios
% scenarios.names={'baseline' 'liberal-baserate' 'conservative-baserate' 'liberal-payoff' 'conservative-payoff' 'low-similarity' 'high-similarity'}; %sb1 scenarios
% scenarios.names={'baseline' 'high-similarity'}; %sb2 scenarios
scenarios.names={'conspaylowsim' 'conspayhighsim'}; %sb3 scenarios
array=ones(1,length(scenarios.names));%scenario array filler

scenarios.baserate=array.*0.5; %Probability of (target vs foil). range 0..1

scenarios.h=array.*10;  %h=benefit of correct detection of target
scenarios.m=array.*-1;  %m=cost of missed detectin of target
scenarios.a=array.*-15;  %a=cost of false alarm to foil
scenarios.j=array.*10;  %j=benefit of correct rejection of foil

scenarios.muTarget=array.*7;  %mean sensory value of target (%-emotion in morph)
scenarios.varTarget=array.*1; %variance of target distribution
scenarios.muFoil=array.*5;    %mean of foil
scenarios.varFoil=array.*1; %variance of foil
scenarios.varFoil(strmatch('conspayhighsim',scenarios.names))=2;
scenarios.varTarget(strmatch('conspayhighsim',scenarios.names))=2;

xstep=.1; %controls "sensory acuity," after a fashion
% xstep=1; %controls "sensory acuity," after a fashion
scenarios.x_range=1:xstep:11; %the array of points at which utility will be calculated
end



function plots=define_plots
% x.on set to: 1=plot it, 0=skip it.
%% DISTRIBUTIONS
plots.Splus_distn.on = 1;           %Distn of S+/target.
plots.Splus_distn.color='g';
plots.Splus_distn.linewidth=2;

plots.Sminus_distn.on = 1;          %Distn of S-/foil.
plots.Sminus_distn.color='b';
plots.Sminus_distn.linewidth=2;

plots.cd_ara.on = 0;                %CDF envelope of S+/target.
plots.cd_ara.color='g';

plots.fa_ara.on = 0;                %CDF envelope of S-/foil.
plots.fa_ara.color='b';


%% CLASSIC UTILITY FN
plots.cl_ara.on = 1;                %classic util fn
plots.cl_ara.color='k';


%% THRESHOLD
plots.threshold.on = 1;            %threshold
plots.hstloc.on = 0;               % threshold as zero of HotSpot fn

plots.threshold.color='k';         %use these settings for HSTloc also
plots.threshold.linewidth=2;
plots.threshold.min = -0.1;        %threshold min pt
plots.threshold.max = 0.2;         %threshold heigth


%% HOTSPOT UTILITY FN, CRITERIA
plots.hs_ara.on = 0;                %hotspot util fn
plots.hs_ara.color='k';

plots.HS_linear_scale.on = 0;       %HS response probability gradient (lin scaled HS fn)
plots.HS_linear_scale.color='k';

plots.minhotspotloc.on = 0; %criterion @ min of HotSpot fn (S+ shift)
plots.minhotspotloc.color='b';
plots.minhotspotloc.min = -5;    %threshold min pt
plots.minhotspotloc.max = 5;     %threshold heigth

plots.maxhotspotloc.on = 0; %criterion @ max of HotSpot fn (S- shift)
plots.maxhotspotloc.color='g';
plots.maxhotspotloc.min = -5;    %threshold min pt
plots.maxhotspotloc.max = 5;     %threshold heigth


%% ROC
plots.roc.on = 0;                   %ROC curve
plots.indiffence_line.on = 0;       %indifference line

%% PSYCHOMETRIC FN
plots.pmetric.on = 0;                   %ROC curve
end



