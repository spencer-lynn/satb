function trigger=io64daq(trigger)
% SAtb fn: trigger=io64daq(trigger)
% - Use io64daq.m instead of trigger_port.m for 64-bit Windows 7+.
% - Output is a struct, so not backwards compatible with SATB's earlier DAQ toolbox-based trigger code. 
%   -- In old code (eg, show_stim_trigger), calls to trigger_port.m returned var "onset_time".
%   -- Replace that with call to this fn, returning "trigger.onset_time".
% 
% Where: 
% TRIGGER is a struct with fields:
% - trigger.Command {'init','writeport','readport'}, used in switch stmt
% - trigger.Trigger_Port is a handle to the io64 interface object (ie, the parallel port).
%                The Port is set by this script when called with Command='init'.
% - trigger.Port_init_status is a status flag when called with Command='init'.
% - trigger.Port_Address is the hexidecimal physical address of the port, passed in as a string.
%                To determine this address, open Control Panel/Device manager. 
%                In the tree-view list, view entries under Ports (COM & LPT).
%                Right click on the desired Printer port (eg, LPT1). 
%                Select Properties/Resources, where you see will entries for I/O Range.
%                Use the starting value of the first range (eg, '0378' is the typical base-address for LPT1)
%                Other methods may give the address with a &H or 0x prefix (0x0378). 
%                Those prefixes denote that what follows is in hexidecimal. You can remove the prefix).
% - trigger.onset_time (in seconds) is GetSecs (a PsychToolbox fn) called just before trigger is sent to port.
% - trigger.Trigger_Value is the value associated with the Event_Code to read/wright, integer in range = 0-255.
% - trigger.Trigger_Duration (in seconds), used to the port to 0 (trigger off) following call to WaitSecs (a Psychtoolbox fn).
% 
% Command = 'init' sets values for fields Trigger_Port, Port_init_status
% Command = 'writeport' requires fields Trigger_Port, Port_Address, Trigger_Value, Trigger_Duration
%           and sets values for field onset_time
% 
% The idea here is that these fields are named and set in a list file for stimuli, feedbacks, etc.
% 
% Because trigger is a struct, you can pass the whole trial_info struct cell-array vector and
% as long as these expected fields are present in that vector it should work regardless
% of whatever else might be in that vector.
% 
% Uses: IO64, Psychtoolbox.
% 
% About IO64: On 64-bit Windows 7 and above, Matlab will not access the parallel port using DAQ toolbox anymore.
% IO64 is a third-party package to get around this.
% See: http://apps.usd.edu/coglab/psyc770/IO64.html and docs distributed in satoolbox/3rd_party/IO64_daq
% - Use of embedded calls to io64 will cause microsecond delays. Use naked calls to io64 for maximum speed.
% (and the swtich stmt is also slow).
% 
% See Signals Approach Toolbox function trigger_demo.m for more.
% Contact Spencer Lynn, spencer.lynn@gmail.com, with questions.
%% %%%%%%%%%%%%%%%%%%%%%%%%%%

trigger.onset_time=NaN; %initialize

switch trigger.Command{1}
    case 'init'
        %'might need to add {}s to extract data from cell.
        try
            %1. Create IO64 interface object
            trigger.Trigger_Port = io64(); %Call w/no input params to initialize parallel port.
            
            %2. Install the inpoutx64.dll driver.
            trigger.Port_init_status = io64(trigger.Trigger_Port); %Call with 1 input object and 1 output var to get status.
            
            %3. Set status = 0 if installation successful.
            if(trigger.Port_init_status ~= 0)
                disp('IO64 input/output object installation failed in call to io64daq.m.')
                trigger.Port_init_status
            end
            %trigger %print to command window
        catch TriggerError
            disp('case=init error in io64daq.m.')
            TriggerError.message
        end %try
        
    case 'writeport'
        %'might need to add {}s to extract data from cell.
        try            
            %disp('trigger ON')
            trigger.onset_time=GetSecs;
            io64(trigger.Trigger_Port,hex2dec(trigger.Port_Address),trigger.Trigger_Value)
            
            %Here, stop all MatLab processes, including stimulus-duration timing (CPU can still do it's thing).
            WaitSecs(trigger.Trigger_Duration);
            io64(trigger.Trigger_Port,hex2dec(trigger.Port_Address),0) % Turn the event off.
            %disp('trigger OFF') 
            %trigger %write to command window
        catch TriggerError
            disp(strcat(['SAtb Warning: ',trigger(1).Event_Name{1},' trigger not sent to port by io64daq.m.']))
            TriggerError.message
        end %try
        
    case 'readport'
        %This CASE not intended for use, but provided here because it's an IO64 feature.
        try
            trigger.Trigger_Value = io64(trigger.Port,hex2dec(trigger.Port_Address));
        catch TriggerError
            disp('case=readport error in io64daq.m.')
            TriggerError.message
        end %try
        
end %switch


end %main fn



