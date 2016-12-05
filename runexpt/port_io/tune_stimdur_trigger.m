function tuned_stim_dur=tune_stimdur_trigger(target_info,following_info)
%SAtb FUNCTION TUNE_STIMDUR_trigger(target_info,following_info)
% - calls show_stim_trigger for both target and following stims.
% - Use 'tune' as trigger code (must be in triggers-list file)

%Where: target_info,following_info = list files contents specifying stimulus screens.
%       following_info is optional. It left left empty, target is followed by flipt to blank screen.
%  
%Uses: SAtoolbox infolists, show_stim, load_stim routines to
% determine waitSecs duration needed to achieve intended stimulus duration
% in Psychtoolbox to overcome a ca. 30 msec over-shoot of duration due to SAtoolbox code execution for
% show_stim -> load_stim -> get_signal -> load_stim -> flip (start target stim) ...
% show_stim -> load_stim -> flip (start following stim)
% = this sequence currently takes about 30 msec on my dev computer.
%Likely from load_stim's disk read for images, text? Ideally, need to pre-make
%textures for fixation, main stims, response windows. For payoffs, can only
%do the contant parts, then would need to append the texture with updates.
% 
% Fn returns "tuned_stim_dur", the duration to use in WaitSecs calls.
%
% If tuning presentation of a file (eg, pictures) rather than PTB-generated
% stimuli (eg, text, Gabors, or line-draws), then SAtb's global "stimfolder" needs to be set before calling
% this function, so it knows where to find those stimuli.
%
%CHANGE LOG
% 8/8/11 - Bug fix, Updated for SAtb-v3 (using utd.m as example)
% - renamed counter from i to ct, fixes sometime bug re i=imaginary
% - over-shoot down to 18 msec
% - deleted methods-structure (see depricated version)
% 10/17/12 
% - added "deal"ing assignmnet of short following-stim duration. Deal needed to handle cases when following_info contained more than one stim (eg, trials rather than single line in listfile).
% - increased integer from 1 to 10 for better accuracy at 250 ms requested dur. interger=1 was working fine for shorter requests.
% - made following_info optional - defaults to flip-to-blank if f_i is not passed in.
% 10/22/12
% - Forked from orginal to add triggers to target and following show_stim calls, with show_stim_trigger.
% - Use 'tune' as trigger code (must be in triggers-list file). 
% - strmatch it every time to account for duration of that match.
% 20160816 need to switch from trigger_port to io64daq. See mods in show_stim_trigger.m
%%%%%%%
%%

target_stim_dur=target_info.Stimulus_Duration; %Desired stimulus duration
[following_info.Stimulus_Duration]=deal(0.050); %Set following stim dur to short (for fast auto-looping below)

%% Acheive arbitrary accuracy by rounding stim dur as an integer
% - can't recall what this does, actually. Might be needed for short tuning to durations (like 30msec)
integer=10;%increase (eg, x10) for greater accuracy if target_stim_dur has more significant digits
ct=0; %counter for number divisions by 10
stim_dur=target_stim_dur; %init with desired stim dur
while stim_dur<integer
    stim_dur=stim_dur*10; %shift decimal place to make an stimdur an integer
    ct=ct+1; %keep track of number of shifts
end %while
rounded_target_stim_dur=(ceil(stim_dur))/(10^ct);

timings=tuning_loop(target_stim_dur,rounded_target_stim_dur,target_info,following_info); %Do the tuning
% ...where timings = [actual_durations requested_stim_dur]
% Uncomment to view:
% disp('actual_durations requested_stim_dur')
% timings

sorted_timings=sortrows(timings,1); %sort by first col (durations)


%% Determine the requested-duration resulting in the actual-duration that is
% closest to the target-duration. 
% It's not necessarily the last request.
% Uncomment to view:
% disp('actual_durations requested_stim_dur')
% timings %Only last duration should be less than target duration.
% sorted_timings

diff1=abs(sorted_timings(1,1)-target_stim_dur); %minimum will be <target duration.
diff2=abs(sorted_timings(2,1)-target_stim_dur); %penultimate will be >target, but perhaps closer than min.
if diff2<=diff1
    final_duration=sorted_timings(2,1);
    requested_duration=sorted_timings(2,2);
else
    final_duration=sorted_timings(1,1);
    requested_duration=sorted_timings(1,2);
end


%% Display results for logging
Tuning_Results_in_secs={target_stim_dur rounded_target_stim_dur timings(2,1) final_duration requested_duration;'= target dur' '= round target' '= initial dur' '= final dur' '= requested dur'}'
disp(strcat(['Initial difference = ',num2str((timings(2,1)-target_stim_dur)*1000),' msec.']))
disp(strcat(['Final difference = ',num2str((final_duration-target_stim_dur)*1000),' msec.']))

tuned_stim_dur=requested_duration;
end %main


%% main tuning loop
function dataout=tuning_loop(target_stim_dur,rounded_target_stim_dur,target_info,following_info)
global conditions triggerinfo

errflag=0;
decriment=.001; %=1 msec: amount to lower waitsec duration in each loop-thru. Can take a long time if initial difference is large, but usu ~20 cycles.
nstim=numel([target_info.Stimulus]);
stim_dur=target_stim_dur+decriment;
stimulus_duration=rounded_target_stim_dur+1;
counter=1;

% READOUTS - Uncomment to view.
% nstim
% rounded_target_stim_dur
% stim_dur

%Prep for triggers
%Write trigger details to stiminfo go show_stim_trigger can send proper event, given signal.
%Use 'tune' as trigger code (must be in triggers-list file). strmatch it every time to account for duration of that match.
conditions.triggerID=strmatch('tune',[triggerinfo.Event_Code],'exact'); %Suss trigger for this trial type ('tune' must match entry in trigger_list).

conditions.xtrial=1;
show_stim_trigger(target_info(1)); %get m-files into memory.


while stimulus_duration(counter)>rounded_target_stim_dur
    
    if stim_dur(counter)<=0
        errflag=1;
        break;
    end
    
    [target_info.Stimulus_Duration]=deal(stim_dur(counter)); %replace with new stimdur to try, used by show_stim for that
    stimnum = ceil(nstim.*rand(1,1)); %pick a random stimulus to show
    conditions.xtrial=stimnum;
    
    %NOTE In SAtb, masking, response windows, payoff deliveries are done by
    %making sequential calls to show_stim.m (show_stim doesn't itself call screen(flip) 
    %at the end of it's stimulus duration).
    %
    %     Here, the key processes is: show a stimulus for a given length of
    %     time, where that time is: onset of target (eg, a face) until
    %     either onset of (flip to) next stim (the mask or response window or payoff delivery)
    %     including any loading time for next stim (in subsequent show_stim call).
    %     So, it's the loading->flip of the following stim (eg, backmask) that
    %     causes an increase in target's duration on-screen above what's intended.
    
    %     ml_time=tic; %VERBOSE uncomment to see ML's rough estimate (doesn't include processes prior to next flip).
    conditions.triggerID=strmatch('tune',[triggerinfo.Event_Code],'exact'); %Suss trigger for this trial type ('tune' must match entry in trigger_list).
    [~,targetStartTime,~,~]=show_stim_trigger(target_info(stimnum)); %show main stim
    %     toc(ml_time) %VERBOSE uncomment to see ML's rough estimate (doesn't include processes prior to next flip).
    
    %If no following_info provided, follow target with a flip-to-blank. 
    %- Note:tic/toc shows that this if-statement only adds a fraction of ms to overall time to execute these lines, so will ignore it.
    if isfield(following_info,'Stimulus')
        conditions.triggerID=strmatch('tune',[triggerinfo.Event_Code],'exact'); %Suss trigger for this trial type ('tune' must match entry in trigger_list).
        [~, followStartTime, ~, ~]=show_stim_trigger(following_info(1)); %show following stim
    else
        [~, followStartTime, ~]=Screen('Flip',target_info(stimnum).wptr); %end stim pres with flip to blank prior to add'l delays from subsequent code.
    end
    
    counter=counter+1;
    stimulus_duration(counter)=followStartTime-targetStartTime;
    stim_dur(counter)=stim_dur(counter-1)-decriment;
    
    % READOUTS - Uncomment to view.
    %[stim_dur followStartTime-targetStartTime]
end %while untuned

dataout=[stimulus_duration' stim_dur'];

if errflag
    error('Implemented stimulus sequencing method is unable to attain requested duration (in tune_stimdur.m).')
end
end %fn

