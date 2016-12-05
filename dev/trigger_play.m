function trigger_play(codes,repetitions,iti)
% SAtb fn: trigger_play(codes [,repetitions,iti]) -- Play with trigger events sent through Windows parallel port.
% Where:
%   codes = Decimal or binvec event code. Can be a vector of different codes.
%   repetitions = number of times to send trigger in quick succession. Defaults to 1.
%   iti = inter-trigger-interval, for chained events (like shock), value
%     in seconds. For, say, shock repetitions, this needs to be
%     ~5ms longer than the the programmed duration of stimulation.
% 
% Notes:
% Our Grass stimulator will send a shock for codes >=128.
%  - decimal=128 is binvec [0 0 0 0 0 0 0 1] (ie, only bit 7 ON). Run dec2binvec(128) -- NOT dec2bin!
%  - In MindWare's BioLab Acquisition 3.0.4, opening the port sends a code=255 glitch, which will deliver shock!
% 
% ? Sometimes there's a trigger 'bounce' - 2nd duplicate event logged 2 ms later in Biolab.

%% Open link to parallel port for output of event codes, shock triggers to physio lab.
% See init_dioport.m for more info.
global parallel_port
if isempty(parallel_port) %if port exists already, don't make a new one
    hlines=0:7; %Parallel port bit designations: pins 9 to 2 (of 25) are bits [7 6 5 4 3 2 1 0].
    direction='out'; %To create output lines on port.
    parallel_port=init_dioport('parallel','LPT1',hlines,direction); %Create link to pararallel port for trigger output. Display details in cmd window.
end

%% Define event characteristics
trigger.Trigger_Port=parallel_port; % The port (a dioobj or uddobj #). See init_dioport.m
trigger.Trigger_Duration=0.001; % Sets the port to 0 following WaitSecs of this duration. This may or may not control shock duration, depending on hardware.

try
    reps=repetitions;
catch
    reps=1;
end
try
    pause=iti;
catch
    pause=0;
end


%% Send trigger
% See trigger_port.m for more info.
t0=GetSecs;
for c=1:numel(codes)
    trigger.Trigger_Value=codes(c); % The binary or decimal state to send, ie, Event_Code.
    trigger %Display trigger information in cmd window.
    for i=1:reps
        trigger_onset_time=trigger_port(trigger);
        WaitSecs(pause);
    end %for
end %each code
duration=trigger_onset_time-t0;
disp(strcat(['Trigger sequnce rough duration(secs): ' num2str(duration)]))

end %fun
