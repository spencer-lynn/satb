function sigmoid_fit_inspector(mood_conditions,sdt_scenarios,start_trial)
%FUNCTION SIGMOID_FIT_INSPECTOR
%
% USAGE: >>sigmoid_fit_inspector('mood','scenario',start_trial) 
%           where: 
%                 moods ='neutral' 'positive' 'negative'
%                 scenarios = 'baseline' 'baseline2' 'payoff' 'baserate' 'similarity'
%                 start_trial = say, 1..20, used to skip "warm up" trials

global datapath outputPath datafile_suffix
global numStimuli numRatings stimNames
global lable_string delimiter fid columnheadings minimumRT chrDelimit %Variables available to all Data Processes
global condition scenario stimset block trialnum objnumber objname objtype behavior outcome payoff responsetime points

global ttl_trials ignore_final_trials %for automation of pmetric processing permutations
ttl_trials_perms=[178 200];
ignore_final_trials_perms=[38 0];
pm_lable={'mintr' 'maxtr'};

toggle_warnings('off') %turn various ML computation warnings on/off

%%% Set the working directory: expects a 'data' folder containing subjects' data files.
myname=strcat(mfilename,'.m'); %Get name of the currently running function, append .m to it.
mypath=which(myname); %Get the directory path of this currently running function.
s=strfind(mypath,myname); %Find the name of the file in the path.
mypath=mypath(1:s-1); %Over write that path, eliminating the file name from the end of it.

datafolder='data';
datafile_suffix='.dat';
expt='sap2';
stimNames={'stim1.tif' 'stim2.tif' 'stim3.tif' 'stim4.tif' 'stim5.tif' 'stim6.tif' 'stim7.tif' 'stim8.tif' 'stim9.tif' 'stim10.tif' 'stim11.tif' };
numRatings=9; %number of confidence rating options
minimumRT=80; %minimum acceptible response time (msec) to consider a trial as valid: Trials with RT below this are excluded from most analyses.

datapath=strcat(mypath,datafolder,'/'); %write summary data output file to the same location as this m-file.
outputPath=strcat(mypath,datafolder,'/'); %write summary data output file to the same location as this m-file.
cd(outputPath); %Set the MatLab working directory to the root path of the currently running m-file.
d=dir(strcat('*',datafile_suffix)); %get list of all data files
numStimuli=length(stimNames);

subjectfilename=d.name
[condition scenario stimset block trialnum objnumber objname objtype behavior outcome payoff responsetime points]=read_data(subjectfilename,datapath);


mood_conditions={mood_conditions}; %These need to be cell arrays for historical reasons
sdt_scenarios={sdt_scenarios};
for c=1:length(mood_conditions)
    currentCondition=mood_conditions{c};
    for s=1:length(sdt_scenarios)
        yfit=zeros(1,numStimuli)*NaN;
        threshold=NaN;
        currentScenario=sdt_scenarios{s};
        
        for p=1:2
        ttl_trials=ttl_trials_perms(p); %settings for trials that pmetric includes in determining gradient
        ignore_final_trials=ignore_final_trials_perms(p);

        response_gradient=do_pmetric(currentCondition,currentScenario,start_trial); %PARAMS=condion,scenario,write[1/0]
        %[sum(isnan(response_gradient)) numStimuli] %uncomment to check that at least some gradients are valid
        if sum(isnan(response_gradient))<numStimuli %Do following only if current mood + param combo produced valid resonses for current subject (ie, was delivered and passes min RT tests)

            %Visually check best fit method after threshold WARNINGs
            [threshold yfit gy gn]=sigmoid_fit(1:numStimuli,response_gradient,'inflection',0,1); %PARAMS=x,y,constrain,plot
            lable_string=strcat([upper(currentCondition) ' ' upper(currentScenario) ':inflectionpt,unconstrained,' pm_lable(p) start_trial]); %Use for labeling graphs
            title(lable_string)
            [threshold gy gn]
            
            [threshold yfit gy gn]=sigmoid_fit(1:numStimuli,response_gradient,'inflection',1,1); %PARAMS=x,y,constrain,plot
            lable_string=strcat([upper(currentCondition) ' ' upper(currentScenario) ':infflectionpt,constrained,' pm_lable(p)]); %Use for labeling graphs
            title(lable_string)
            [threshold gy gn]

            [threshold yfit gy gn]=sigmoid_fit(1:numStimuli,response_gradient,'yfitmid',0,1); %PARAMS=x,y,constrain,plot
              lable_string=strcat([upper(currentCondition) ' ' upper(currentScenario) ':midpt,unconstrained,' pm_lable(p)]); %Use for labeling graphs
            title(lable_string)
            [threshold gy gn]
            
            [threshold yfit gy gn]=sigmoid_fit(1:numStimuli,response_gradient,'yfitmid',1,1); %PARAMS=x,y,constrain,plot
             lable_string=strcat([upper(currentCondition) ' ' upper(currentScenario) ':midpt,constrained,' pm_lable(p)]); %Use for labeling graphs
            title(lable_string)
            [threshold gy gn]
        end
       end
    end %for each scenario type
end % for each mood condition

fclose('all'); %close all open files
toggle_warnings('on') %turn warnings back on 
end %fun
%%






function indiv_gradient=do_pmetric(mycondition,myscenario,start_trial)
%% PMETRIC.m - psychometric fn
global condition scenario stimset block trialnum objnumber objname objtype behavior outcome payoff responsetime points %data file column-fields
global numSubblocks stimNames minimumRT
global ttl_trials ignore_final_trials
%Define which trials to analyze:
%A sap2 scenario has 200 yes/no trials that COULD be analyzed = 178 drawn from signal distn + 22 not from distn that get confidnce ratings.
%Structure = 140 trials (in 14 loops of 10) + a final 38 (=178) interspersed with 22 y/n stims (=200) + 22 1..9 confidnce ratings).
%  ttl_trials=200; %= either 178 or 200
%  ignore_final_trials=0; %number final trials to exclude (eg 0 or 38, if think interpersed ratings might effect responses)
%-Doesn't make sense to ignore final any trials if using all 200.

numSubblocks=1; %number of subblocks to break the analysis into. Should evenly divide ttl_trials.
%start_trial=10; %eg, 1..20; use this to ignore early "warm up" trials.

%[mycondition myscenario]
%Filter current datafile:
flt_data=filter_data_array({condition scenario block objtype objname behavior responsetime},mycondition,1); %Get trials from current condition
flt_data=filter_data_array(flt_data,myscenario,2);%Get trials from current SDT scenario
flt_objname=flt_data{5};
flt_behavior=flt_data{6};
l1=strcmp('trials',flt_data{3}); %Get the main trials, exclude other kinds of responses (mood ratings, etc).
l2=flt_data{7}>=minimumRT; %exclude trials with impossibly small RTs (ie, subject not attending)

if ttl_trials == 178 % USE BELOW TO ANALYZE JUST SIGNAL-DRAWN TRIALS
    l3=strcmp('+',flt_data{4}); %Filter by "correct answer" to exclude stims not drawn from a signal distribution (ie, confidence rated stims).
    l4=strcmp('-',flt_data{4}); %Filter by "correct answer" to exclude stims not drawn from a signal distribution (ie, confidence rated stims).
    logicaltest=logical(l1.*l2.*(or(l3,l4))); %Construct the main logical array, a filter to extract the target data
else %if ttl_trials==200 % USE BELOW TO ANALYZE ALL TRIALS REC'V A YES OR NO RESPONSE (incl the confidence rated trials not drawn from actual signla distn).
    % this makes better estimates than above
    l3=strcmp('xConfidence_rating',flt_data{5}); %find the ratings themselves, for exclusion
    l3=~l3; %this will excluding the ratings
    logicaltest=logical(l1.*l2.*l3); %Construct the main logical array, a filter to extract the target data
end
    
% switch ttl_trials
%     case ttl_trials==178 % USE BELOW TO ANALYZE JUST SIGNAL-DRAWN TRIALS
% 
%     case ttl_trials==200 % USE BELOW TO ANALYZE ALL TRIALS REC'V A YES OR NO RESPONSE (incl the confidence rated trials not drawn from actual signla distn).
%         % this makes better estimates than above
%         l3=strcmp('xConfidence_rating',flt_data{5}); %find the ratings themselves, for exclusion
%         l3=~l3; %this will excluding the ratings
%         logicaltest=logical(l1.*l2.*l3); %Construct the main logical array, a filter to extract the target data
%     otherwise
%         disp('ttl_trials must be 178 or 200 in do_pmetric.')
% end %switch
%%
flt_objname=flt_objname(logicaltest);
flt_behavior=flt_behavior(logicaltest);

if size(flt_objname,1) ~=0
    ttl_trials=size(flt_objname,1); %redefine incase some trials filtered out
end
trialsPerSubblock=ttl_trials-((start_trial-1)+ignore_final_trials);%

%size(flt_objname) %uncomment to check that data is actually being sent to pmetric. Should see 3 lists of ca 200 rows.
indiv_gradient=pmetric(numSubblocks,trialsPerSubblock,flt_objname,flt_behavior,stimNames,'psychometric'); %returns the x,y points of subject's actual gradient (relative proportion of presses; not modelded)
end %%fn



function mydata=filter_data_array(mydata,filter_string,data_column)
%% Filter data for current condtion, scenario
logicaltest=logical(strcmp(filter_string,mydata{data_column}));
[r c]=size(mydata);
for i=1:c %for each column of data
    mydata{i}=mydata{i}(logicaltest);
end
end %% fn


function toggle_warnings(flag)
%% turn various ML computation warnings on/off
warning(flag,'stats:nlinfit:IterationLimitExceeded') %generated by sending null data thru sigmoid_fit.m
warning(flag,'stats:nlinfit:IllConditionedJacobian') %generated when pmetric fn is un-sigmoid. Trapped by sigmoid_fit.m
warning(flag,'stats:nlinfit:Overparameterized') %
warning(flag,'MATLAB:nearlySingularMatrix') %from call to inv() in nlinfit after bad Jacobians
warning(flag,'MATLAB:rankDeficientMatrix') %
warning(flag,'MATLAB:singularMatrix') %
end %fn

