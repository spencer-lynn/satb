function satb_demo_process
%% Preliminary processing of data from satb_demo experiment dat files.
%
% Place this file in the experiment's program directory.
% It will process .dat files in the data folder and
% output "expt-name_processed_data.csv" to the data folder.
% Import the processed file into Excel, SPSS, etc.
%
% edit satb_demo_process  %<--- Triple-click and press ENTER to edit processing parameters.
%
%Version 7/17/12.1
%Requires SAtb (Signals Approach toolbox)
%
% Expt design:
% scenarios={'conspaylowsim' 'conspayhighsim'}; random block order across ppts.
% - These don't correspond to sb1, sb2 scenarios (sb1's conspay had lower stdevs).
% 200 trials per block.
% 
%%%

global datapath outputPath datafile_suffix listfolder
global stimNames
global label_string delimiter fid columnheadings minimumRT chrDelimit %Variables available to all Data Processes
global condition scenario trialtype block trialnum objnumber objname objtype behavior outcome payoff responsetime points


%% Runtime params
prt.expt='satb_demo'; %experiment name
prt.tmethod='inflection'; %sigmoid_fit param
prt.constrain=0; %sigmoid_fit param
prt.plot=0; %sigmoid_fit param
prt.ignore_final_trials=0; %do_pmetric param (not currently implemented)
prt.minimumRT=250; %minimum acceptible response time (msec) to consider a trial as valid: Trials with RT below this are excluded from most analyses.
prt.maximumRT=10000; %max acceptible response time (msec) (not currently implemented)

stimNames={'stim1.tif' 'stim2.tif' 'stim3.tif' 'stim4.tif' 'stim5.tif' 'stim6.tif' 'stim7.tif' 'stim8.tif' 'stim9.tif' 'stim10.tif' 'stim11.tif' };
processes={'trials'}; % no rating trial types in this expt.
blocks={'conspaylowsim' 'conspayhighsim'}; %Data are processed in this order, but order was randomized for ppts.



%% Set the working directory
% expects a 'data' folder containing participants' data files.
[myname mypath]=setdir(mfilename);
listfolder='lists/'; %Folder containing stimulus characterization list text files, used by readstim
datafolder='data/';
datafile_suffix='.dat';

%% init some additional globals
toggle_warnings('off') %turn various ML computation warnings on/off
outputPath=strcat(mypath,datafolder); %write summary data output file to the same location as this m-file.
datapath=strcat(mypath,datafolder); %write summary data output file to the same location as this m-file.
cd(outputPath); %Set the MatLab working directory to the root path of the currently running m-file.
fid = fopen(strcat(outputPath,['_' prt.expt '_processed_data.csv']),'wt'); %open file on disk to write processed data
fprintf(fid,'%s\n',''); %Write empty line at top of output file (will later hold data column names)
delimiter='%i,'; %used to separate array elements in output file.
chrDelimit=',';
d=dir(strcat('*',datafile_suffix)); %get list of all data files
numSubjects=length(d);

%% Run main processesing sequences
% open each subject's file and processes it
% data is written "very wide" : one line per subject for every within-subject condition, scenario, etc
for n=1:numSubjects
    prt.filename=d(n).name;
    underscores=findstr(prt.filename,'_');
    dotdat=findstr(prt.filename,datafile_suffix);
    pptID=prt.filename(max(underscores)+1:dotdat-1); %participant ID

    prt.filename
    cd(outputPath); %reset path to /data, must be getting redirected by sxb/model m-files.
    %% Get the data
        dataout=importdata(strcat(datapath,'/',prt.filename)); %importdata is a builtin ML fn
        headers=dataout.textdata(1,:); %column header line gets separated from data rows
        for i=1:(size(dataout.textdata,2))
            dataout.(strtrim(headers{i}))=dataout.textdata(2:end,i);
        end
        
        hcol=size(dataout.textdata,2)-size(dataout.data,2);
        for i=1:(size(dataout.data,2))
            dataout.(strtrim(headers{hcol+i}))=dataout.data(:,i);
        end
        
        pptid=dataout.PptID; %combo of pptID.expt#, will differ from pptID if file has been renamed.
        study=dataout.Study;
        scenario=dataout.Scenario;
        stimset=dataout.StimSet;
        stimname=dataout.Stimulus_name;
        outcome=dataout.Outcome;
        responsetime=dataout.RT;
        
        %Recast behavior from cell of strings to double for use by pmetric fn.
        for i=1:size(dataout.Behavior,1)
            behavior(i)=str2double(dataout.Behavior{i});
        end
        behavior=behavior';    

%% Suss gen'l ppt infos
    fprintf(fid,'%s,',pptID); %Write data to disk
    columnheadings='pptID'; %accrete col headers listing
        
    fprintf(fid,'%s,',prt.filename); %Write data to disk
    columnheadings=strcat(columnheadings,',','File'); %accrete col headers listing
    
    try
        fprintf(fid,'%s,',dataout.Scenario{2}); %look to hardcoded row# for data
    catch
        fprintf(fid,'%s,','Error');
    end
    columnheadings=strcat(columnheadings,',','Block1'); %accrete col headers listing

    
    try
        fprintf(fid,'%s,',dataout.StimSet{400}); %look to hardcoded row# for data
    catch
        fprintf(fid,'%s,','Error');
    end
    columnheadings=strcat(columnheadings,',','low_stimset'); %accrete col headers listing

    try
        fprintf(fid,'%s,',dataout.StimSet{200}); %look to hardcoded row# for data
    catch
        fprintf(fid,'%s,','Error');
    end
    columnheadings=strcat(columnheadings,',','high_stimset'); %accrete col headers listing

    
    
%% Process the data
for p=1:numel(processes) %loop through processes for each class of data
    currentProcess=processes{p};
    switch currentProcess
        
        case 'trials'
            for b=1:numel(blocks) %(baseline scenario vs param scenario)
                prt.target_scenario=blocks{b};
                flt_data=filter_data_array({scenario stimname behavior outcome responsetime},prt.target_scenario,1); %extract data for current block
                switch prt.target_scenario
                    case 'conspaylowsim' %filter-in the baseline block trials.
                        prt.label='low'; %re-write brief label
                    case 'conspayhighsim' %exclude the baseline block trials
                        prt.label='high'; %re-write brief label
                    otherwise
                        disp('Label not recognized near line 150.')
                end % switch
                %class(flt_data{5}) %Uncomment to check that you've grabed the right trials
                
                do_SDTmeasures(flt_data,prt);
                do_sigmoids(flt_data,prt);
            end %each w/in-subj condition
            
            
    end %switch processing by block type / data class
end %for processing all blocks
fprintf(fid,'%s\n','end of line'); %newline after each subject
end %for each subject

%% Cleanup
columnheadings=strcat(columnheadings,',','EOL');
fprintf(fid,'%s\n',columnheadings); %Write names for data columns as last row in file. Not ideal method, and colheads depend on success of final subject
fclose('all'); %close all open files
toggle_warnings('on') %turn warnings back on
end %%fun


function do_SDTmeasures(flt_data,prt)
%% Calc basic SDT measures
global delimiter chrDelimit fid columnheadings 
%flt_data already filtered = {scenario stimname behavior outcome responsetime}
% Define which trials to analyze: A sb3 trial block has 200 target/foil signal-drawn trials in it.

%Filter current datafile: exclude confidence or other trials not involving stimuli drawn from signal distributions.
flt_outcome=flt_data{4}; %grab the response outcomes
minrtflt=flt_data{5}>=prt.minimumRT; %create logical filter to exclude trials with impossibly small RTs (ie, subject not attending)
maxrtflt=flt_data{5}<=prt.maximumRT; %Mark as 1 = usable. Exclude trials with very long RTs (ie, subject not attending)
logicaltest=logical(minrtflt.*maxrtflt); %put the filters together
flt_outcome=flt_outcome(logicaltest); %get the outcomes resulting from valid response outcomes

%% Conventional measures
datatype.type='frequency'; %we're evaluating frequencies of CDs, etc

counts=evaluate(flt_outcome,'raw_counts',datatype); %return counts of CDs, etc
fprintf(fid,delimiter,counts); %write measure to file
fprintf(fid,delimiter,sum(counts)); %write measure to file
newheader=strcat(',',prt.label,'_ctCD',',',prt.label,'_ctFA',',',prt.label,'_ctMD',',',prt.label,'_ctCR',',',prt.label,'_numTrials');
columnheadings=strcat(columnheadings,newheader); %accrete col headers list

dprime=evaluate(flt_outcome,'dprime',datatype);
fprintf(fid,delimiter,dprime); %write measure to file
newheader=strcat(',',prt.label,'_sensitivity');
columnheadings=strcat(columnheadings,newheader); %accrete col headers list

bias=evaluate(flt_outcome,'c',datatype);
fprintf(fid,delimiter,bias); %write measure to file
newheader=strcat(',',prt.label,'_bias');
columnheadings=strcat(columnheadings,newheader); %accrete col headers list

%% Distance to LOR
try
    lor_params=eval(strcat(prt.expt,'_sxb(prt.target_scenario)')); %Returns LOR model curve for given scenario.
    [distance direction]=sxb([dprime bias],lor_params,0); %Returns distance-to-LOR.
catch
    distance=NaN;
    direction=NaN;
end
fprintf(fid,delimiter,[distance direction distance.*direction]);
columnheadings=strcat(columnheadings,',',prt.label,'_dOpt,',prt.label,'_direction,',prt.label,'_dSigned');

%% points, from filtered trials.
scenarios=eval(strcat(prt.expt,'_model')); %returns struct of parameter values for each scenario in expt.
h=scenarios.h(strmatch(prt.target_scenario,scenarios.names));
a=scenarios.a(strmatch(prt.target_scenario,scenarios.names));
m=scenarios.m(strmatch(prt.target_scenario,scenarios.names));
j=scenarios.j(strmatch(prt.target_scenario,scenarios.names));
points_flt=((counts(1)*h)+(counts(2)*a)+(counts(3)*m)+(counts(4)*j));%points earned on trials passing filters

fprintf(fid,delimiter,points_flt); %write measure to file
newheader=strcat(',',prt.label,'_pts');
columnheadings=strcat(columnheadings,newheader); %accrete col headers list
end %%fn


function do_sigmoids(flt_data,prt)
%% Get pmetric fn and sigmoid fit estimates
global delimiter chrDelimit fid columnheadings
global stimNames
%flt_data already filtered = {scenario stimname behavior outcome responsetime}
% Define which trials to analyze: A sb3 trial block has 200 target/foil signal-drawn trials in it.

%Filter current datafile: exclude confidence or other trials not involving stimuli drawn from signal distributions.
flt_stimname=flt_data{2};
flt_behavior=flt_data{3};

minrtflt=flt_data{5}>=prt.minimumRT; %create logical filter to exclude trials with impossibly small RTs (ie, subject not attending)
maxrtflt=flt_data{5}<=prt.maximumRT; %Mark as 1 = usable. Exclude trials with very long RTs (ie, subject not attending)
logicaltest=logical(minrtflt.*maxrtflt); %put the filters together

flt_stimname=flt_stimname(logicaltest);
flt_behavior=flt_behavior(logicaltest);

% size(flt_stimname) %uncomment to check that data is actually being sent to pmetric. Should see 1 list of ca 200 rows.
response_gradient=pmetric(flt_stimname,flt_behavior,stimNames,'psychometric'); %returns the x,y points of subject's actual gradient (relative proportion of presses; not modelded)
sigmoid_fit_output=sigmoid_fit(1:numel(stimNames),response_gradient.pm,prt.tmethod,prt.constrain,prt.plot,prt.filename); %PARAMS=x,y,tmethod,constrain,plot

fprintf(fid,'%s',strcat(num2str(sigmoid_fit_output.threshold),chrDelimit));
columnheadings=strcat(columnheadings,',',prt.label,'_threshold');
fprintf(fid,'%s',strcat(num2str(sigmoid_fit_output.p4slope),chrDelimit));
columnheadings=strcat(columnheadings,',',prt.label,'_thr_slope');
fprintf(fid,'%s',strcat(num2str(sigmoid_fit_output.guessed_yes),chrDelimit));
columnheadings=strcat(columnheadings,',',prt.label,'_guessed_yes');
fprintf(fid,'%s',strcat(num2str(sigmoid_fit_output.guessed_no),chrDelimit));
columnheadings=strcat(columnheadings,',',prt.label,'_guessed_no');

fprintf(fid,'%s',num2str(response_gradient.pm,delimiter));
columnheadings=strcat(columnheadings,',',prt.label,'_pm1,',prt.label,'_pm2,',prt.label,'_pm3,',prt.label,'_pm4,',prt.label,'_pm5,',prt.label,'_pm6,',prt.label,'_pm7,',prt.label,'_pm8,',prt.label,'_pm9,',prt.label,'_pm10,',prt.label,'_pm11'); %P[Go] at each stimulus

fprintf(fid,'%s',num2str(sigmoid_fit_output.yfit,delimiter));%fit P[Go] at each stimulus
columnheadings=strcat(columnheadings,',',prt.label,'_yfit1,',prt.label,'_yfit2,',prt.label,'_yfit3,',prt.label,'_yfit4,',prt.label,'_yfit5,',prt.label,'_yfit6,',prt.label,'_yfit7,',prt.label,'_yfit8,',prt.label,'_yfit9,',prt.label,'_yfit10,',prt.label,'_yfit11');

if prt.constrain==0
    %If ran as uncontrained, then rerun to get r-sq to [0-1] contrained sigmoid.
    sigmoid_fit_outcome=sigmoid_fit(1:numel(stimNames),response_gradient.pm,prt.tmethod,1,0,prt.filename);
end
fprintf(fid,'%s',num2str(sigmoid_fit_output.rsq,delimiter));
columnheadings=strcat(columnheadings,',',prt.label,'_rsqC');

end

