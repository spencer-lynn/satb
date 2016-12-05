function onset_time=trigger_port(trigger)
% SAtb fn: onset_time=trigger_port(trigger)
% where trigger is a struct with fields:
% - trigger.Trigger_Port is the port (a dioobj or uddobj). See init_dioport.m
% - trigger.Trigger_Value is the binary or decimal state to send, ie, Event_Code
% - trigger.Trigger_Duration sets the port to 0 following WaitSecs.
% ...the idea being that these fields are named and set in a list file for stimuli, feedbacks, etc.
% Because this is a struct, you can pass the whole trial_info struct cell-array vector and 
% as long as these expected fields are present in that vector it should work regardless
% of what ever else might be in that vector.
% 
% Uses Matlab's Data Acquisition Toolbox (may not function on MacOS), Psychtoolbox.
% See Signals Approach Toolbox function trigger_demo.m for more.
% Contact Spencer Lynn, spencer.lynn@gmail.com, with questions.

% trigger

try
% disp('trigger ON')
putvalue(trigger.Trigger_Port,trigger.Trigger_Value); %Turn the event on.
onset_time=GetSecs;

%Here, stop all MatLab processes, including stimulus-duration timing (CPU can still do it's thing).
WaitSecs(trigger.Trigger_Duration);
putvalue(trigger.Trigger_Port,0); % Turn the event off.
%   disp('trigger OFF')

catch TriggerError
    onset_time=GetSecs;
%     disp(strcat(['SAtb Warning: ',trigger(1).Event_Name{1},' trigger not sent to port by trigger_port.m.']))
%     TriggerError.message
end %fn