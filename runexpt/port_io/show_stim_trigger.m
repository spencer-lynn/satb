function [response,startrt,endrt,trigger_onset]=show_stim_trigger(trial_info)
%SAtb function: [response startrt endrt trigger_onset]=show_stim_trigger(mystiminfo)
% 
% Uses PTB to show stimulus on-screen, and sends digital event code out a port.
% Event duration must be less than stimulus duration because: trigger->flip. 
% - If not, need to code a way to turn off the code from the calling fn.
% 
% Change log:
% 20110207 - forked from original show_stim.m (itself modifed for new listfile structure, etc):
%          - added code to send triggers to hardware port
% 20160816 - Switch trigger method from ML's DAQ toolbox to 3rd party IO64,
%          - ML DAQ version of this script has been depricated.

global keyinfo keyfilter currentkeys conditions triggerinfo

Screen('Close') %close all open textures (from prior trial). Needed for Windows. 
response={'null'};
endrt=NaN;

%% Load the stimulus
%Here, control of trial can pass to xfn referenced in stiminfo (for loading complex stimuli, masking, etc)
load_stim(trial_info); %load trial's on-screen components to Screen's back-buffer
%Control is released from loadstim back here to showstim. Any xfn run by load_stim should be ready for the flip screen, below.

%% stimdur comes from trial_info (which, for main expt'l trials, is usually the trial_list file, not the stimulus_list file).
% If the expt uses tune_stimdur, then the tuned duration should be put into trial_info prior to calling show_stim. 
% Overwriting of a list's stimdur with a tunedStimDur should be done in main experimental code, like in or block_trials.

%% Trigger duration must be less than stimulus duration because trigger shuts down ML with WaitSecs.
% So the trigger duration is effectively added to time the stimulus is on-screen.
trial_info.Stimulus_Duration=trial_info.Stimulus_Duration-triggerinfo(conditions.triggerID).Trigger_Duration; %Correct desired on-screen stim duration for trigger duration.

%% Flip screen to show whats been loaded
[VBLTimestamp,startrt,FlipTimeStamp]=Screen('Flip', trial_info.wptr); %Show image on monitor. Set startrt=StimulusOnsetTime.

%% Send event code/trigger here (details specified in a triggerinfo (a listfile), indexed by triggerID).
%Replace calls to trigger_port with io64daq, which returns the modified triggerinfo line struct (new with .onset_time [used below]).
%trigger_onset=trigger_port(triggerinfo(conditions.triggerID)); %Call trigger_port.m to send an event to a port. All Matlab/PTB processes stop for given duration.
io64_output=io64daq(triggerinfo(conditions.triggerID)); %Call io64daq.m to send an event to a port. All Matlab/PTB processes stops for given duration.
trigger_onset=io64_output.onset_time; %pass value for backward compatibility.

%% Poll for responses up until stimdur, then release control to calling fn

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
response=response{1}; %sometimes it seem keyinfo match can return >1 response (or used to)
end %fn