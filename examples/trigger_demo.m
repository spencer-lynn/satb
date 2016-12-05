function trigger_demo(method)
% SAtb fn: trigger_demo(method)
% 
% Where method = 
%      'daqtb' to use calls to ML's Data Acquisition Toolbox.
%      'io64' to use 3rd party parallel port access. Use this under 64-bit Windows 7 and above.
%         (for which DAQ TB no longer has parallel port access).
%         - See io64daq.m for more informtion.
% Uses the Signals Approach Toolbox (SAtb, email spencer.lynn@gmail.com). 
% Some called fns may also make calls to Psychtoolbox <http://psychtoolbox.org/>.
% - eg, calls to WaitSecs in io64daq.m
% 
% Change log:
% - 20110912 - started.
% - 20160511 - Added switch 'method', calls to io64 for 64-bit Win compatibility.
%
%%%%%%%%%%%%%%%%%%%%

if nargin==0
    disp('trigger_demo.m requires a method. Defaulting to:')
    method='daqtb' %for backward compatibility.
end

spoof_trigger_info
switch method
    case 'daqtb'
        %Use ML's DAQ toolbox. This will fail under 64-bit Windows 7+.
        daqtb_step1_setup %Open port, define trigger values.
        daqtb_step2_send_trigger(1) %We'll invoke trigger #1.
        
    case 'io64'
        Port_Address='D010'; %Hex string, like '0378' (omnit any 0x or &H prefix). D010-D017, D000-D003
        trigger_num=1; %spoofed trigger listfile line to send
        io64_step1_setup(Port_Address,trigger_num) %Open port, define trigger values.
        io64_step2_send_trigger(trigger_num) %We'll invoke trigger #1.
end %switch
end %fn

function spoof_trigger_info
global triggerinfo
%% Create trigger-values common to any calling method.
%Use SAtoolbox syntax:
% [fName mypath]=setdir(mfilename); %Get name of the currently running function, set current directory
% trigger_list_example=strcat(mypath,'/trigger_list_example.txt'); %This demo relies on 'trigger_list_example.txt' being in same directory is this m-file, trigger_demo.m)
% triggerinfo=read_list(trigger_list_example); %An SAtb listfile = a text file describes trigger names, codes, ports, durations. Used by fetch_signal, accrue_payoffs, etc.

%Do-it-yourself:
triggerinfo(1).Event_Name={'Demo trigger'}; %Human-readable information.
triggerinfo(1).Event_Code={'x'}; %Handy code that can be matched to user input, written to data file, whatever.
triggerinfo(1).Note={'Your comments here.'}; %Documentation.
triggerinfo(1).Trigger_Value=10; %Decimal represenataion of the the trigger value to be received by remote hardware, sent over the port.
triggerinfo(1).Trigger_Duration=0.0100; %Duration of trigger event, in seconds. Not a stimulus duration, just the duration of the trigger itself. Smaller is better.
% 
end

function io64_step1_setup(Port_Address,trigger_num)
%Do this once, as part of experiment initialization
%% Open a link to computer's parallel port for output of trigger/event codes.
global triggerinfo
%fill in any add'l needed triggerinfos.
triggerinfo(1).Command={'init'}; %Command for calls to event-based io64daq.m
triggerinfo(1).Port_Address={Port_Address}; %physical address of the port.
io64_output=io64daq(triggerinfo(trigger_num)) %Call io64daq.m to send an event to a port. All Matlab/PTB processes stops for given duration.
triggerinfo(1).Trigger_Port=io64_output.Trigger_Port; %Var to hold handle to the io64 interface object (ie, the parallel port)..

end %fn
function io64_step2_send_trigger(trigger_num)
%% Do this every time you need a trigger/event code sent.
global triggerinfo
% Call io64daq to send the trigger. Returns the time the trigger was sent.
triggerinfo(trigger_num).Command={'writeport'}; %Command for calls to event-based io64daq.m
io64_output=io64daq(triggerinfo(trigger_num)) %Call io64daq.m to send an event to a port. All Matlab/PTB processes stops for given duration.
end %fn

function daqtb_step1_setup
%Do this once, as part of experiment initialization
%% Open a link to computer's parallel port for output of trigger/event codes.
global parallel_port triggerinfo

triggerinfo(1).Trigger_Port={'parallel_port'}; %Port over which to send the trigger event. SAtb only works on parallel port at present (9/12/2011).
%% For increased speed, dereferece the port ID strings in trigger, replace with the port uddobj/dioobj value.
for i=1:length(triggerinfo)
    triggerinfo(i).Trigger_Port=eval(triggerinfo(i).Trigger_Port{1});
end
triggerinfo %print to command-window

hlines=0:7; %Parallel port bit designations: pins 9 to 2 (of 25) are bits [7 6 5 4 3 2 1 0].
direction='out'; %To create output lines on port.
parallel_port=init_dioport('parallel','LPT1',hlines,direction); %Create link to pararallel port for trigger output. The name of capturing variable must match Trigger_Port value in trigger list files.

end %fn
function daqtb_step2_send_trigger(trigger_num)
%% Do this every time you need a trigger/event code sent.
global parallel_port triggerinfo
% Call trigger_port to send the trigger. Returns the time the trigger was sent.
trigger_onset=trigger_port(triggerinfo(trigger_num)) %Call trigger_port.m to send an event to a port. All Matlab/PTB processes stop for given duration.
end %fn

function additional_handy_code
%% The following use additional SAtb functions or depend on conditions set elsewhere.
[response startRT endRT stim_trigger_onset]=show_stim_trigger(stiminfo(mytrial)); %show a stimulus, send a trigger/event codes.

triggerID=strmatch(outcome,[triggerinfo.Event_Code],'exact'); %Suss trigger code for a given keypress outcome.

stimonset_trigger_lag=stim_trigger_onset-startRT;%Time lag (in seconds) btw stim onset times and sending event code to physio acquisition system

end %fn