function ptb_stimdur_test(stimdur)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%SAtb FUNCTION ptb_stimdur_test
% Loop through stimulus presentations in order to time the duration with a photodiode/oscilloscope.
% Provides infinite loop of stimulus displays.
% Press Space-bar, q, Esc, or Return to end the loop.
%
% Usage: ptb_stimdur_test(stimdur)
%
% where:
%     stimdur = (optional) stimulus duration, in seconds. If not supplied here, it will be read in from trials_list.txt.
%
%FEATURES
% Use minimal Psychtoolbox code (ie, Screen('flip') to show stimuli for set duration, to check duration with photodiode/oscilloscope.
%
%VERSION
% ptb_stimdur_test, 7/31/12, forked from satb_stimdur_test
% Spencer K. Lynn, spencer.lynn@gmail.com
%
%CHANGE LOG
% 7/31/12
% - forked from satb_stimdur_test, which uses more complex code w/ trial structures, etc, that may interfere with timing.
%
%USES
% -Psychophysics Toolbox v3
%
% TO DO
% - add code to send triggers
% - Log data to dat file?
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%
%% critical items to get out of way
%%%%%%%%%%%%%%%%%%%%%%%%%

%% Set randomization seed
clear global
% clc; %Clear ML command window.
KbName('UnifyKeyNames')

%%%%%%%%%%%%%%%%%%%%%%%%%
%% experiment-specific settings
%%%%%%%%%%%%%%%%%%%%%%%%%

%% Set the working directories for the experiment
global listfolder datafolder stimdir %locations of stimuli, parameter files
[exptName mypath]=setdir(mfilename); %Get name of the currently running function, set current directory
listfolder='lists/'; %Folder containing stimulus characterization list text files
datafolder='data/'; %Folder containing stimulus characterization list text files
stimdir='stimuli/'; %Folder containing any stimuli not generated by PsychToolbox drawScreen routines.

%% Open dat & diary files
global fdata %used by prep_datafiles and block-trials.
fdata.datafile_prefix = strcat(exptName,'_'); % name of data file to write to (used by fn Initializers)
fdata.datafile_suffix='.dat';
% fdata.formatStr = '%s\t%s\t%s\t%s\t%s\t%i\t%i\t%s\t%s\t%i\t%s\t%s\t%i\t%i\t%i\n';
% fdata.headerstring='PptID\tStudy\tScenario\tStimSet\tBlock\tTrial\tStimulus_value\tStimulus_name\tResponse_code\tBehavior\tOutcome\tPayoff\tRT\tPoints\tStimulus_duration\n'; %column names for datafile

try
    fdata.participantID=datestr(now,30); %may need MLv2012
catch
    fdata.participantID='DateError'
end
fdata.fname=strcat(fdata.datafile_prefix,fdata.participantID,fdata.datafile_suffix);
fdata.path=datafolder; %includes data/ path
fdata.dataout=[];
% fdata=prep_datafiles(fdata) %open dat & diary files prior to rand, init_ptb so can log information to diary
% fprintf(fdata.fptr,fdata.headerstring); %Write column headings to data file

sessionlog=strcat(fdata.path,fdata.datafile_prefix,fdata.participantID,'_diary.txt');
% diary(sessionlog);
{exptName fdata.participantID fdata.fname} %log in diary


%%  Set experiment specific parameters

soa=0.500; %SOA in seconds, used as inter-trial interval


%% Define and init expt'l CONDITIONS (a global struct)
global conditions
conditions=[]; %Empty any values from prior runs.
conditions.study=exptName;
conditions.ttlPoints=0;
conditions.scenario='test'; %{}'s extract string from cell
conditions.stimset='test_faces1';
conditions %print conditions

%%%%%%%%%%%%%%%%%%%%%%%%%
%% RUN experiment.
%%%%%%%%%%%%%%%%%%%%%%%%%
global w %from init_ptb
init_ptb(1,0); %Start PsychToolBox. flags=hidecursor,pause. Pause=0 since setting a custom "ready" screen in main_inits fn.

trialinfo=read_list(strcat(listfolder,'trials_list.txt')); %Read information about each trial (getsignal xfn, response-code place-holder, duration)
[trialinfo.wptr]=deal(w); %Deal w pointer into all rows of stiminfo struct (creating wptr if necc).
[trialinfo.Stimulus_Duration]=deal(stimdur);
trialinfo(1) %print to command window.

show_intructions
loop_a_stim(trialinfo,stimdur,soa)

cleanup %Diary turned off by cleanup.
end %MAIN FN



%%%%%%%%%%%%%%%%%%%%%%%%%
%% EXPERIMENT-SPECIFIC BLOCK DEFNS
%%%%%%%%%%%%%%%%%%%%%%%%%



function loop_a_stim(trialinfo,stimdur,soa)
global w stimdir conditions
KbWait([], 1); %wait for no key presses
quit=false;
missed=NaN;

stimfilename=strcat(stimdir,conditions.stimset,'/','stim1.tif'); %hard-coded image stimulus, must reside in correct folder.
imdata=imread(stimfilename); %load image file
tex=Screen('MakeTexture', w, imdata); %make texture of image w/reference to main window, w
while quit==false
    
    %% load the stim.
    Screen('DrawTexture', w, tex); %draw image to backbuffer
    
    %% Start the stim
    [VBLTimestamp_on StimulusOnsetTime_on FlipTimeStamp_on]=Screen('Flip', w);% Show image on monitor. Show stim
    flip_tic=tic;
    
    
    %% End the stim with [when]
    [VBLTimestamp_off StimulusOnsetTime_off FlipTimeStamp_off missed]=Screen('Flip', w, StimulusOnsetTime_on+stimdur);% Show blank monitor. End stim
    
    %% End the stim after WaitSecs
%     WaitSecs(stimdur);
%     [VBLTimestamp_off StimulusOnsetTime_off FlipTimeStamp_off]=Screen('Flip', w);% Show blank monitor. End stim
    
    ml_duration=toc(flip_tic);
    
    %% Do the Inter-trial interval
    WaitSecs(soa);
    
    
    %% Timing reports
    ptb_duration_VBLT=VBLTimestamp_off-VBLTimestamp_on;
    ptb_duration_Stim=StimulusOnsetTime_off-StimulusOnsetTime_on;
    ptb_duration_Flip=FlipTimeStamp_off-FlipTimeStamp_on;
    [ptb_duration_VBLT ptb_duration_Stim ptb_duration_Flip ml_duration missed]
    
    %% Check for user-requested break in stim pres loop
    [KeyIsDown, endrt, KeyCode]=KbCheck;
    if KeyCode(KbName('space'))==1
        quit=true;
    elseif KeyCode(KbName('q'))==1
        quit=true;
    elseif KeyCode(KbName('Return'))==1
        quit=true;
    elseif KeyCode(KbName('ESCAPE'))==1
        quit=true;
    end
    
end
end


function show_intructions
global w
%% Put block2 instructions on screen
line1=70;
nextline=30;
Screen('TextSize', w, 24);
Screen('TextFont',w, 'Arial');
Screen('DrawText', w, 'Ready.', 10, line1, 255);

Screen('DrawText', w, 'Press space-bar to begin looping stimulus display.', 10, (line1+6*nextline), 255);
Screen('DrawText', w, 'Press space-bar, q, esc, or return to end the stimulus display loop.', 10, (line1+8*nextline), 255);

Screen('Flip', w); %show text

%% Wait for user response
[KeyIsDown, endrt, KeyCode]=KbCheck;
while KeyCode(KbName('space'))==0 % loop until valid key is pressed
    [KeyIsDown, endrt, KeyCode]=KbCheck; %check for key presses
    WaitSecs(0.001); % Wait 1 ms before checking the keyboard again to prevent overload of the machine at elevated Priority()
end %while key not pressed
Screen('Flip', w); %show empty screen
WaitSecs(0.100); % aesthentic pause before starting
end