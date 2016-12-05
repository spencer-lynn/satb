function get_signal_trigger
%SAtb FUNCTION get_signal_trigger. Indended to be called as a list-file xfn
%Calls fetch_signal to obtain a source = posobjtype or negobjtype, with probability = alpha
% and a sigval = value# (on x-axis sensory domain) of stim to be shown: the stim number. 
% Don't confuse sigval with the experimental block's current
% trial number in stiminfo or with the value of a payoff.
% Overwrites these items in global "stiminfo", which can then be passed to show_stim.
% Or, can be passed parameters rather than use globals
% 
%CHANGE LOG:
% 1/10/11 - moved code to update stimulus duration (in stiminfo) with targetStim_dur 
%           from here (fetch_signal, following other updates to stiminfo) to main expt code, where it needs to be used
%           (show stim doesn't have access to the global stiminfo, just a local version that get's applied to ALL stims).
% 
% 1/15/11 - depricated older version. Now uses global struct siganl_params for
%           all values. Incorporated assign_signal into this code.
% 
% 2/7/11  - mods for new stiminfo structure, load_stim
%         - renamed this m-file "get_signal" from "fetch_signal".
%         - moved assign_signal out (again) to separate mfile (which is now known as fetch_signal)
%         - replaced calls to depricated xtrial (from old loadstim) with conditions.xtrial, which is set in main block_trials
%         - would be nice to make this independent of conditions.xtrial
% 
% 11/13/12 - Mirrored 8/1/11 change in non-trigger version: added conditions.stimID=stimnum. Useful for stims, like Gabors,
%          where Stimulus field doesn't specify a unique signal ID (see utd.m expt use of Gabors).
% 
% % % % % % 

global stimulus_list %= info from the stimulus definition list file
global stiminfo triggerinfo%=info from the calling block's trial list file (may not be exactly the same as stimulus_list)
global conditions
% global xtrial targetStim_dur

% disp(strcat('fetchsig says xtrial = ',num2str(xtrial))) %Uncomment to monitor

[source stimnum]=fetch_signal; %do the randomized signal/stim polling
conditions.stimID=stimnum; %log the fetched stimulus into the conditions-global in case needed elsewhere.

%Rewrite stiminfo (=current block's trial-list) to have this randomly-assigned stim's informaiton in it, for behavioral scoring and data logging
stiminfo(conditions.xtrial).Stimulus=stimulus_list(stimnum).Stimulus; %Put this trial's stimulus name into the block's stiminfo so it'll get written to data file
stiminfo(conditions.xtrial).Response_Code={source}; %Update stiminfo's "object type" with notation for correct response (= S+ or S- signal source)
stiminfo(conditions.xtrial).Stimulus_Type=stimulus_list(stimnum).Stimulus_Type; %Update stiminfo's stim type from x to what ever is specified in main stimulus-list

% Write trigger details to stiminfo to show_stim_trigger can send proper event given signal.
conditions.triggerID=strmatch(source,[triggerinfo.Event_Code],'exact'); %Suss trigger for given trial type (source-string must match entry in trigger-list file).

%NOTE: these two calls to loadstim are not nec equivelent.
load_stim(stimulus_list(stimnum)) %Load stimnum, the assigned stimulus value with features of stimulus_list (the stimulus definition list file)
% loadstim(xtrial,stiminfo) %Don't use this here. Load stim# xtrial with features from stiminfo (the trial definition list file) 

%If called as a stim-list's xfn, control now passes back to show_stim for
%the flip to display this stimulus.
end % fun