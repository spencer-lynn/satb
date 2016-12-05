function [response startrt endrt]=show_stim(trial_info)
%SAtb FUNCTION [response behavior responsetime]=SHOWSTIM(mystiminfo)
%
% Change log:
% 2/7/11
% - modified for new stiminfo structure (also keyinfo)
% - uses one line of trial_info rather than whole stimlist info
% - windowptr now part of trial_info struct (mystiminfo)
% - uses new load_stim

global keyinfo keyfilter currentkeys %all defined by get_keys.m

% global stiminfo %uncomment to monitor
% [mystiminfo{2}(trial) mystiminfo{4}(trial) mystiminfo{12}(trial)]
% [stiminfo{2}(trial) stiminfo{4}(trial) stiminfo{12}(trial)]

Screen('Close') %close all open textures (from prior trial). Needed for computers with low video mem (eg, stock Windows machines).
%depricated: respwinddur=mystiminfo{13}(trial);%preload prior to use in a GetSecs loop
response={'null'};
endrt=NaN;

%% Load the stimulus
%Here, control of trial can pass to xfn referenced in stiminfo (for loading complex stimuli, masking, etc)
%load_tic=tic; %$ Uncomment to check timing w/ Matlab code,
load_stim(trial_info); %load trial's on-screen components to Screen's back-buffer
%load_toc=toc(load_tic) %$ Uncomment to check timing w/ Matlab code,
%% Flip screen to show whats been loaded
%Control is released from loadstim back here to showstim. Any xfn run by loadstim should be ready for the flip screen, below.

%flip_tic=tic; %$ Uncomment to check timing w/ Matlab code, excluding call to load_stim.
[VBLTimestamp startrt FlipTimeStamp]=Screen('Flip', trial_info.wptr);% Show image on monitor. SET startrt


%% Examine timings
% global fVBLTime fStimOnSet fFlipTime tVBLTime tStimOnSet tFlipTime %used for examining timing
%{
%Examine stim durs from xSignal to showstim
%Forward mask duration
tVBLTime-fVBLTime
%tStimOnSet-fStimOnSet
%tFlipTime-fFlipTime

%Target duration
VBLTimestamp-tVBLTime
%startrt-tStimOnSet
%FlipTimeStamp-tFlipTime
%}


%% Poll for responses up until stimdur, then release control to calling fn
% stimdur comes from stiminfo (which, for main expt'l trials, is usually the trial_list file, not the stimulus_list file).
% If the expt uses tune_stimdur, then the tuned duration should be set into mystiminfo prior to calling show_stim.
%   - For fixations, masks, and response windows insertion of tuned duration can be done in main code.
%   - For main exptl target stims, insertion of tuned duration might get done in block_trials.

while (GetSecs-startrt)<=trial_info.Stimulus_Duration
    [KeyIsDown, checktime, KeyCode]=KbCheck; %check keyboard status
    if sum(KeyCode(keyfilter))==1 && sum(KeyCode(~keyfilter))==0 %require 1 key from filter set only.
        % strmatch(KbName(KeyCode),currentkeys) %uncomment to check
        response=keyinfo(strmatch(KbName(KeyCode),currentkeys)).Response_Code; %Retrive the response code associated with they key that was pressed
        endrt=checktime; %set end point of RT if valid key pressed
        if trial_info.Stimulus_Duration==Inf
            break;%trial ends
        end
    end
    WaitSecs(0.001);  %Wait 1 ms before checking the keyboard again to prevent overload of the machine at elevated Priority()
end %stimulus duration

%toc(flip_tic) %$ Uncomment to check timing w/ Matlab code.

response=response{1}; %Extract contents of cell. Sometimes it seems keyinfo match can return >1 response (or used to)
end %fn