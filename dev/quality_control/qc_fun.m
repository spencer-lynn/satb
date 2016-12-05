function qc_fun(process,cond1,cond2)
%----
%FUNCTION qc_fun: Quality Control for satb data
%
%edit qc_fun  %<-- Triple-click & [RETURN] for useage and more information.
%----

%{
PROCESSING SEQUENCE
qc_fun('setup')
qc_fun('open'[,'file name'])
qc_fun('set_conditions','mood condition','parameter condition')
qc_fun('rt')
qc_fun('set_rt','min RT'[,'max RT'])
qc_fun('trimtrials'[,'measure 1'[,'measure 2']] %only on Baseline1 scenario
qc_fun('set_start',trial#) %only on Baseline1 scenario
qc_fun('presses') %manually set odd data points to NaN
qc_fun('threshold')
qc_fun('refresh') %recalculate threshold excluding bad points
qc_fun('write')
qc_fun('set_conditions','mood condition','parameter condition')
qc_fun('open'[,'file name'])
qc_fun('roc',plot-flag [,'method']) %optional
%}

%% Chang Log:
% 3/21/11
% - updated calls to evaluate for new evaluate requirements

%% To Do
%{
Calc area under ROC (incr resolution, extrap-y, sum y-values),
fit ROC to pwr fn
get indiff slope from ROC+outcomes, get Thr from that
check repeated pFA values on sap2 DEV-subject.
%}
%%


global flt_dataset raw_dataset response_gradient fname qcPanelHandles callbackqc callingQCfn
global files stimNames numStimuli mood_condition sdt_scenario start_trial minimumRT maximumRT go_direction datafile_suffix

if nargin==0; process='setup'; end

switch process
    case 'dev'
        
    case 'setup'
        %% SET UP MAIN PROCESSING PARAMS, DEFAULTS
        %toggle_warnings('off') %turn various ML computation warnings on/off
        callbackqc=mfilename; %get name of this m-file for use by callback fns in qc_panal GUI.
        evalin('base','global start_trial')
        evalin('base','global flt_dataset') % Any vars that will be manipulated by data-brushing need to be globalized in both this fn & base ML workspace.
        for c=1:numStimuli % Any vars that will be manipulated by data-brushing need to be globalized in both this fn & base ML workspace.
            myfield=strrep(stimNames{c},'.','');
            evalin('base',['global xval' myfield])
            evalin('base',['global yval' myfield])
        end
        %openvar('flt_dataset')
        
        
        
    case 'open'
        %% OPEN A SUBJECT'S DATA FILE
        fname=cond1
        set(qcPanelHandles.current_file,'String',fname) %in SAP2, 2nd entry is neutral:baseline
        raw_dataset=read_data(fname,cd);
        eval([callingQCfn '(''openfile'')']) %call EXPTLqc routine without knowing its name
        eval([callingQCfn '(''set_analysis_params'')']) %recursively call this fn without hardcoding its name
        resetGUIfields %Reset cond,start,rt GUI boxes
        extract_keypress_data('trials') %reset the data set w/new params

        
        
    case 'set_conditions'
        %% Pass requested EXPERIMENTAL CONDITIONS onto EXPTLqc routine to set
        eval([callingQCfn '(''set_conditions'',cond1,cond2)']) %recursively call this fn without hardcoding its name
        eval([callingQCfn '(''set_analysis_params'')']) %recursively call this fn without hardcoding its name
        resetGUIfields %Reset cond,start,rt GUI boxes
        extract_keypress_data('trials') %reset the data set w/new params
       
                
    case 'rt'
        %% HISTOGRAM OF RESPONSE TIMES
        if nargin==1;cond1=100;end
        numbins=floor(max(flt_dataset.responsetime)/cond1); %histo in 10msec bins
        correct=logical((strcmp('CD',flt_dataset.outcome)+strcmp('CR',flt_dataset.outcome)));
        incorrect=logical((strcmp('FA',flt_dataset.outcome)+strcmp('MD',flt_dataset.outcome)));
        figure; zoom on
        hist(flt_dataset.responsetime(correct),numbins)
        title('RT Histogram for CORRECT Responses')
        xlabel('Response time (msec)')
        ylabel('Count')
        figure; zoom on
        hist(flt_dataset.responsetime(incorrect),numbins)
        title('RT Histogram for INCORRECT Responses')
        xlabel('Response time (msec)')
        ylabel('Count')
        
        
        
    case 'set_minrt'
        %% SET RESPONSE TIME MIN & MAX FILTERS
        minimumRT=cond1
        extract_keypress_data('trials')
        
        
    case 'set_maxrt'
        %% SET RESPONSE TIME MIN & MAX FILTERS
        maximumRT=cond1
        extract_keypress_data('trials')
        
        
    case 'trimtrials'
        %% EXAMINE D' OVER ALL TRIALS TO SEE IF NEED TO DROP INITIAL TRIALS
        if nargin==1
            cond1='dprime';
            cond2='bias';
        elseif nargin==2
            cond2=cond1;
            cond1='dprime';
        end
        figure; hold on; zoom
        measure=do_trimtrials(cond1);
        
        plot(measure,'bo-')
        legend('Sensitivity')
        xlabel('Trial number')
        ylabel('Performance')
  
%             %Attempt to overlay two graph axes
%             line([1:numel(flt_dataset.points)],flt_dataset.points,'color','r')
%             ax1=gca;
%             set(ax1,'YColor','b')
%             
%             ax2 = axes('Position',get(ax1,'Position'),...
%                 'XAxisLocation','top',...
%                 'YAxisLocation','right',...
%                 'Color','none',...
%                 'XColor','k','YColor','r');
%             line([1:numel(measure)],measure,'color','b');
%             

%             measure=do_trimtrials(cond2);
%             plot(measure,'r')
%             plot(flt_dataset.points,'r')

        
    case 'set_start'
        %% SET START-TRIAL FILTER
        if nargin<2
            disp('SET_START requires a start trial: ''set_start'',75.')
        else
            start_trial=cond1
        end
        extract_keypress_data('trials')
        
        
        
        
    case 'presses'
        %% LOOK AT RAW KEY PRESS DATA
        init_stimarrays
        plot_responses
        
        
        
    case 'threshold'
        %% PLOT THRESHOLD
        pmethod='psychometric';
        pmetric_output=pmetric(flt_dataset.objname,flt_dataset.behavior,stimNames,pmethod) %returns the x,y points of subject's actual gradient (relative proportion of presses; not modelded)       
        response_gradient=pmetric_output.pm;
        tmethod='inflection'
        constrain_yfit=false
        qc_threshold(tmethod,constrain_yfit);
        
        
        
        
    case 'refresh'
        %% REFRESH THRESHOLD PLOTS
        update_calcs
        qc_fun('threshold')
        
        
        
    case 'roc'
        %% PLOT RECIEVER OPERATING CHARACTERISTIC
        if nargin==2;cond2='average';end
        original_flt_dataset=flt_dataset;
        extract_keypress_data('none'); %need unfiltered data set for this
        do_roc(go_direction,cond1,cond2)
        flt_dataset=original_flt_dataset;
        
        
        
    case 'write'
        qcdata.fname=fname;
        qcdata.mood=mood_condition;
        qcdata.scenario=sdt_scenario;
        qcdata.starttrial=start_trial;
        qcdata.behavior=flt_dataset.behavior;
        qcdata.objname=flt_dataset.objname;
        sname=strcat([strrep(fname,datafile_suffix,''),'_',mood_condition,'_',sdt_scenario]);
        save(sname,'qcdata')
        qcdata
        
    case 'help'
        hfile='qc_help.txt';
        hpath=which(mfilename);
        s=strfind(hpath,mfilename); %Find the name of the file in the path.
        hpath=hpath(1:s-1); %Over write that path, eliminating the file name from the end of it.
        hpath=strcat(hpath,hfile);
        show_help(hpath);
        
    otherwise
        disp(strcat(['Requested QC PROCESS not recognized in ' strcat(mfilename,'.m')]))
end %main switch
end %fn
%%

function resetGUIfields
global qcPanelHandles minimumRT maximumRT start_trial
        set(qcPanelHandles.minrt,'String',num2str(minimumRT))
        set(qcPanelHandles.maxrt,'String',num2str(maximumRT))
        set(qcPanelHandles.starttr,'String',num2str(start_trial))
end


function [pCD pFA]=do_roc(go_direction,plotflag,rating_measure)
%% Uses ROC_FROM_CONFIDENCE.m - sensitivity via ROC based on sampled confidence ratings
% Where:
% go_direction; %OPTIONS: 'right' | 'left'= "Go"-side of threshold.
% rating_measure='average'; %OPTIONS: 'average'  Take mean of ratings for each stimulus
%         'maximum'  Use maximum of ratings for each stimulus rated. Sounds good but can have the effect of decreasing count of common mid-ratings
%         'separate' Use each separate rating given
global flt_dataset
global numRatings stimNames
rating_values=1:numRatings;

%[pCD pFA]=roc_from_confidence(go_direction,rating_values,rating_measure,flt_block,flt_objtype,flt_objname,flt_behavior,stimNames);
[pCD pFA]=roc_from_confidence(go_direction,rating_values,rating_measure,flt_dataset.block,flt_dataset.objtype,flt_dataset.objname,flt_dataset.behavior,stimNames);
% Returns array of points to draw ROC, unprocessed as measure of sensitivity
if plotflag==1
    plot_roc(pCD,pFA)
end
end %fn


function plot_roc(probCD,probFA)
%% write data, draw plots
[numSubjects c]=size(probCD);
symbol={'o-'; 'x-' ;'*-' ;'s-' ;'d-'; 'v-' ;'p-' ;'h-' ;'^-' ;'<-'; '>-'; '.-'}; %plot symbols, combine with other line types if need more
figure; hold on;
colorOrder=jet(numSubjects);
ca={1:numSubjects}; %cell array for building legend
for s=1:numSubjects %for loop not required for actual plot, but needed for using different symbols, construcing legend
    %   plot(probFA(s,:)+s/50,probCD(s,:)-s/50,symbol{s},'Color',colorOrder(s,:),'LineWidth',2) %+/- s/50 staggers x/y points for readability
    plot(probFA(s,:),probCD(s,:),symbol{s},'Color',colorOrder(s,:),'LineWidth',2)
    legendText(s)={num2str(ca{1}(s))}; %a shame to do this so many times, only needs to be done once for ALL plots
end
%title(strcat([upper(condition) ' Reciever Operating Characteristic']));
%legend(legendText)
xlabel('P[FA]');
ylabel('P[CD]');
end % fn



function forward_measure=do_trimtrials(measure)
%%
global flt_dataset
% This code does a "forward" trim-trial to locate the trial at which performance peaked.
% It calculates dprime #trials times, each time reducing the number of trials
% used in the calculation by triming off earlier trials, one at a time.
% So, the meaure for Trial=1 on the x-axis uses all trials.
% But by end of trials, only a few tirals are being used to calc performance.
% Once you get ~20 trials from end of file, performance fluctuates a lot.

forward_outcome=flt_dataset.outcome; %Copy data to working data array. One ppt's data: outcomes=column of CDs, FAs, etc, by trial
backward_outcome=flt_dataset.outcome;

forwardTrim=true(size(flt_dataset.outcome)); %A logical index array.
backwardTrim=true(size(flt_dataset.outcome));

forward_measure=ones(size(flt_dataset.outcome))*NaN; %results array
backward_measure=ones(size(flt_dataset.outcome))*NaN;

datatype.type='frequency';
for f=1:size(flt_dataset.outcome,1) %For each trial...
    forward_measure(f)=evaluate(forward_outcome,measure,datatype); %EVALUATE ignores non-CD,etc codes such as D-/D+
    %forward_measure(f)=evaluate(forward_outcome,measure,1);
    %     for b=1:size(flt_dataset.outcome,1)
    %         backward_measure(b)=evaluate(backward_outcome,'dprime',1); %EVALUATE ignores non-CD,etc codes such as D-/D+
    %         backwardTrim(numel(flt_dataset.outcome)-b+1)=0;
    %         backward_outcome=flt_dataset.outcome(backwardTrim);
    %     end %for
    %need to write row of backd' to a bigger var
    forwardTrim(f)=0; %Set logical index to FALSE for current trial number. Won't get used in next round.
    forward_outcome=flt_dataset.outcome(forwardTrim); %Copy trimmed version of dataset to working data array.
end %for
% figure; hold on; zoom
% plot(forward_measure)
% plot(backward_measure)
end %fun




function update_calcs
%% transfer changes in stimpres_ara to objname,behavior for use by pmetric
global stimNames numStimuli flt_dataset %stimstruct xvalstruct

flt_dataset.objname=[];
flt_dataset.behavior=[];

for c=1:numStimuli
    %Currently, can't just use logical filter on this. But could do it via
    %trial nums
    myfield=strrep(stimNames{c},'.','');
    eval(['global yval' myfield])
    ydata=eval(['yval' myfield]);
    lg=~isnan(ydata); %get indices non-NaNs in the graph data (~= flt_dataset)
    
    flt_dataset.behavior=[flt_dataset.behavior;ydata(lg)]; %append values to new behav
    flt_dataset.objname=[flt_dataset.objname;(lg(lg)*c)]; %append stimnumbers to new objname
end
flt_dataset.behavior=sign(flt_dataset.behavior); %convert to original +1/-1 behav code
flt_dataset.objname=transpose(stimNames(flt_dataset.objname));
end %fn



function init_stimarrays
%%
global stimNames numStimuli
global flt_dataset stimstruct
for c=1:numStimuli
    stimfilt=strcmp(stimNames(c),flt_dataset.objname); %logical filter for every time stim c shown
    denom=(1:size(flt_dataset.behavior(stimfilt)))';
    myfield=strrep(stimNames{c},'.',''); %remove incompat chars from stim names
    stimstruct.(myfield)=flt_dataset.behavior(stimfilt)./denom; %dynamically create struct field
end %for each stim
end %fn



function plot_responses
%%
global stimNames numStimuli stimstruct %stimstruct is buried in an eval-stmts
figure;hold on
for c=1:numStimuli
    myfield=strrep(stimNames{c},'.','');
    eval(['global xval' myfield])
    eval(['global yval' myfield])
    eval(['xval' myfield ' = ones(size(stimstruct.(myfield)))*c;'])
    eval(['yval' myfield ' = stimstruct.(myfield);'])
    plot(eval(['xval' myfield]),eval(['yval' myfield]),'o')
end

xlabel('Stimulus #')
ylabel('<-- Presses to S-       Presses to S+ -->')

hold off;zoom
linkdata on

% These methods didn't work:
% FLAT MAT COLS
%  stimpres_ara=ones(100,numStimuli)*NaN;
%  xvalues=ones(100,numStimuli);
%  figure; hold on;
% for c=1:numStimuli
%     myfield=strrep(stimNames{c},'.','');
%     stimpres_ara(1:size(stimstruct.(myfield),1),c)=stimstruct.(myfield);
%     xvalues(:,c)=xvalues(:,c)*c;
%     plot(xvalues(:,c),stimpres_ara(:,c),'o')
% end
% linkdata on
% hold off;zoom
% title('GO & NOGO at Each Stimulus')

%Plotting from the struct doesn't seem to work AT ALL for linking data to plot on which to brush.
% xvalstruct=stimstruct;
% figure; hold on;
% for c=1:numStimuli
%     myfield=strrep(stimNames{c},'.','');
%     xvalstruct.(myfield)=ones(size(xvalstruct.(myfield)))*c
%     plot(stimstruct.(myfield),stimstruct.(myfield),'o')
% end
end %fn




function qc_threshold(tmethod,constrain_yfit)
%%
global response_gradient
global mood_condition sdt_scenario numStimuli


% sigmoid_fit_output.threshold=threshold;
% sigmoid_fit_output.yfit=yfit;
% sigmoid_fit_output.guessed_yes=guessed_yes;
% sigmoid_fit_output.guessed_no=guessed_no;
% 
% sigmoid_fit_output.p1min=p(1);
% sigmoid_fit_output.p2max=p(2);
% sigmoid_fit_output.p3mu=p(3);
% sigmoid_fit_output.p4slope=p(4);
% 
% sigmoid_fit_output.residuals=R;
% sigmoid_fit_output.jacobians=J;
% sigmoid_fit_output.covariance=COVB;
% sigmoid_fit_output.mse=MSE;

sigmoid_fit_output=sigmoid_fit(1:numStimuli,response_gradient,tmethod,constrain_yfit,1); %PARAMS=x,y,t-method,constrain,plot
%linkdata on

threshold=sigmoid_fit_output.threshold;
yfit=sigmoid_fit_output.yfit;
gy=sigmoid_fit_output.guessed_yes;
gn=sigmoid_fit_output.guessed_no;

lable_string=strcat([upper(mood_condition) ' ' upper(sdt_scenario) ': ' tmethod ' w/ constraint=' num2str(constrain_yfit)]); %Use for labeling graphs
title(lable_string)

disp('Threshold    GuessYes    GuessNO')
[threshold gy gn]
end %fn




function extract_keypress_data(process)
%%
%global mood_condition sdt_scenario
global flt_dataset raw_dataset start_trial minimumRT maximumRT
global ttl_trials ignore_final_trials trialsPerSubblock
global condition datacolumns


conds=fieldnames(condition);
flt_data=filter_data_array({raw_dataset.condition raw_dataset.scenario raw_dataset.block raw_dataset.objtype raw_dataset.objname raw_dataset.behavior raw_dataset.outcome raw_dataset.responsetime raw_dataset.points},condition.(conds{1}),datacolumns.(conds{1})); %Get trials from current condition
numconditions=length(conds);
for i=2:numconditions
    flt_data=filter_data_array(flt_data,condition.(conds{i}),datacolumns.(conds{i}));%Get trials from current SDT scenario
end

    
flt_dataset.block=flt_data{3};
flt_dataset.objtype=flt_data{4};
flt_dataset.objname=flt_data{5};
flt_dataset.behavior=flt_data{6};
flt_dataset.outcome=flt_data{7};
flt_dataset.responsetime=flt_data{8};
flt_dataset.points=flt_data{9};


datafields=fieldnames(flt_dataset);

lgFilternames={'minRTfilter' 'maxRTfilter' 'startTrialFilter' 'sdTrialsFilter' 'confidenceFilter'};
for i=1:length(lgFilternames)
    lgFilter.(lgFilternames{i})=true(size(flt_dataset.(datafields{1})));
end

lgFilter.minRTfilter=flt_dataset.responsetime>=minimumRT; %exclude trials with impossibly small RTs (ie, subject not attending)
lgFilter.maxRTfilter=flt_dataset.responsetime<=maximumRT; %exclude trials with impossibly small RTs (ie, subject not attending)

lgFilter.startTrialFilter=true(size(flt_dataset.(datafields{1})));
if start_trial>1
    lgFilter.startTrialFilter(1:start_trial-1)=false;
end

switch process
    case 'trials'
        lgFilter.sdTrialsFilter=strcmp('trials',flt_dataset.block); %Get the main trials, exclude other kinds of responses (mood ratings, etc).
        lgFilter.confidenceFilter=strcmp('xConfidence_rating',flt_dataset.objname); %find the ratings themselves, for exclusion
        lgFilter.confidenceFilter=~lgFilter.confidenceFilter; %this will excluding the ratings
end %switch

logicaltest=logical(lgFilter.minRTfilter.*lgFilter.maxRTfilter.*lgFilter.sdTrialsFilter.*lgFilter.confidenceFilter.*lgFilter.startTrialFilter);
for i=1:length(datafields)
    flt_dataset.(datafields{i})=flt_dataset.(datafields{i})(logicaltest);
    %NOTE: for d' calcs, this'll have D+/D- code on confidence-rated trials
end

if size(flt_dataset.objname,1) ~=0
    ttl_trials=size(flt_dataset.objname,1); %redefine in case some trials filtered out
end
trialsPerSubblock=ttl_trials-((start_trial-1)+ignore_final_trials);
%size(flt_dataset.objname) %uncomment to check that data is actually being sent to pmetric. Should see 3 lists of ca 200 rows.

end %fn




function mydata=filter_data_array(mydata,filter_string,data_column)
%% Filter data for current condtion, scenario
logicaltest=logical(strcmp(filter_string,mydata{data_column}));
[r c]=size(mydata);
for i=1:c %for each column of data
    mydata{i}=mydata{i}(logicaltest);
end
end % fn


function toggle_warnings(flag)
%% turn various ML computation warnings on/off
warning(flag,'stats:nlinfit:IterationLimitExceeded') %generated by sending null data thru sigmoid_fit.m
warning(flag,'stats:nlinfit:IllConditionedJacobian') %generated when pmetric fn is un-sigmoid. Trapped by sigmoid_fit.m
warning(flag,'stats:nlinfit:Overparameterized') %
warning(flag,'MATLAB:nearlySingularMatrix') %from call to inv() in nlinfit after bad Jacobians
warning(flag,'MATLAB:rankDeficientMatrix') %
warning(flag,'MATLAB:singularMatrix') %
end %fn

