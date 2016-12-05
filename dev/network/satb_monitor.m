function satb_monitor(event,msg)
% Create a custom version of this file for each experiment, like otd_monitor.
% Put that customized m-file into the experiment's directory on the Monitor computer
% (so it has access to all the experiments lists and stimuli.
% - User-supplied values go in the 'user_specs' event, below.
%
% Monitor a Signals Approach Toolbox Experiment over UDP network connection.
% - Creates a UDP Interface Object, which is a type of Instrument Object (see tmtool, Instrument Control Toolbox).
%
% Must provide the STIM computer's (ie, Instrument's) network address or name.
% - Get that by running satb_instrument('local') on STIM.
% STIM computer must be set up as an SATB Instrument (run satb_instrument('init',monitor-address) on STIM.
%
% event='read' expects a line of trial-data from the experiment (ie, as written to Experiment's .dat file).
%
%Contact:
% Spencer Lynn, spencer.lynn@gmail.com
%
%Uses:
% Signals Approach Toolbox v3
% Mathwork's Instrument Control Toolbox
%
% Change Log:
% 1/11/13 - Started.
% 1/15/13 - moved from centeralized version with 'instrument' input paramter to custom version for each expt.
%
%
%To Do:
% - timer object to poll 'read's. see doc timer.
% - send a beep at breaks?
% - check that time stamp (which has a space in it) reads okay from instrument.
% - could actually have the instrument supply the user-specs via cmds issued by monitor.
%    - additional input parameter to pass spp commands for 'write'.
%    - code in satb_instrument to handle any 'write' commands sent from here.
% 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%% Initialize experiment-specific variables
persistent formatStr headerstring instr_address %user-supplied vars
persistent instr_udpobj headers read_input trial plotaxis %program-filled vars

switch event
    
    case 'demo_init' %demo event for working out details.
        %% Spoof an 'init' event
            % --below should get xfered to 'init'--
            satb_monitor('user_specs') %init user-supplied variables
            formatStr=regexprep(formatStr,'i','f'); %Replace i's (from Experiments fdata.formatStr) with f's for textscan() in 'read'.
            figure; hold on %init figure to plot results in 'process'
            plotaxis=gca; %get figure's axis handle
            trial.counter=0; %trial counter, used by 'process'
            
            %Grab data headers for reference during processing.
            h_formatStr=regexprep(formatStr,'f','s'); %Change f's to s's to parse headerstring itself.
            headerstring=regexprep(headerstring,'\\t','\t'); %Replace /t's with actual tab-characters for textscan().
            headerstring=regexprep(headerstring,'\\n',''); %Delete new-line character at end of string.
            headers=textscan(headerstring,h_formatStr); %parse headers into cell array
            %[headers{1:end}]' %print to verify headers
    case 'demo'        
        %% Spoof a 'read' event
        datastr='demo	otd	baseline	karo_f23	trials	1	5	stim5.tif	-	-1	CR	j	900	260	3.00E-01	16/01/2013::17:16:07.712	4.84E-01	1.48E-03	1.43E-03	1.40E-03	3.96E-03	1.33E-03'; %Example line of trial data from OTD
        read_input=textscan(datastr,formatStr); %Parse string to cell-array of varibles.
        %[read_input{1:end}]' %print to verify
        
        satb_monitor('process'); %Process the data string w/ recursive call
        
    case 'process'
        %Put trial-data into a struct, with fields=headers
        trial.counter=trial.counter+1;
        for i=1:(size(headers,2))
            trial.((char(headers{i})))=read_input{i};
        end
        %trial %print to verify

        plot(plotaxis,trial.counter,trial.Points,'o')
    case 'user_specs'
        %% USER SUPPLIED VARIABLES
        %% Network address to computer running the satb experiment.
        %instr_address='192.168.1.106'; %Monitors's IPv4 address
        instr_address='spencer-MBPW7'; %Instrument's Network name
        %instr_address='fe80:0:0:0:d8ab:794b:8022:74c5%17'; %Instrument's MAC address
        
        %% format string of experiment's data file (fdata.formatStr)
        formatStr = '%s\t%s\t%s\t%s\t%s\t%i\t%i\t%s\t%s\t%i\t%s\t%s\t%i\t%i\t%i\t%s\t%i\t%i\t%i\t%i\t%i\t%i\n';

        %% header string (data column names) of experiment's data file (fdata.headerstring)
        headerstring='PptID\tStudy\tScenario\tStimSet\tBlock\tTrial\tStimulus_value\tStimulus_name\tResponse_code\tBehavior\tOutcome\tPayoff\tRT\tPoints\tITI_duration\tTimestamp\tStimulus_duration\tfix_trigger_lag\tstim_trigger_lag\trwin_trigger_lag\toutcome_trigger_lag\tpayoff_trigger_lag\n'; %column names for datafile

        
    case 'local'
        %Return local host (ie, the ACQ or satb_monitor computer) network addresses.
        %Prints a list of localhost addresses for use by satb_instrument.
        %No 'instrument' input parameter required.
        
        %Choose a method of addressing the satb_monitor from the satb_instrument:
        %monitor='192.168.1.104'; %Monitors's IPv4 address
        %monitor='spencer-mbp2'; %Monitors's Network name
        %monitor='fe80:0:0:0:cabc:c8ff:fef0:73d0%5'; %Monitors's MAC address
        
        udp_info=instrhwinfo('udp');
        udp_info.LocalHost
        
    case 'init'
        %Initialize this satb Monitor and connect to an satb Instrument.
        %'instrument' input parameter = Instrument's network address (from satb_instrument('local'))
        
        monitor_port=9090; %9090=default UDP port. 4012 is common in examples. Can be same as instrument_port.
        instr_port=9090;
        
%         try
        instr_udpobj = udp(instr_address,'RemotePort',instr_port,'LocalPort',monitor_port); %Create a UDP object, associated with a remote host, the instrument.
%         catch
%             if isequal(msg,'demo')
%                         instr_udpobj = udp('localhost','RemotePort',instr_port,'LocalPort',monitor_port); %Create a UDP object, associated with a remote host, the instrument.
%             end
%         end
       
        try
            fopen(instr_udpobj); %bind the remote-obj to local-socket / Connect to the instrument / Connect the UDP object to the remote host
        catch err
            err.message
            error('In case of fopen() errors, run tmtool to disconnect any open UDP Interface Objects.')
        end
       %instr_udpobj %uncomment to print
        
        %Init other vars
        formatStr=regexprep(formatStr,'i','f'); %Replace i's (from Experiments fdata.formatStr) with f's for textscan().
        
    case 'read'
        %Read data sent from satb_instrument.
        %'instrument' input parameter = Instrument's udp-object (output of satb_monitor('init',) command).
        %Can be number (fread), text (fscanf), binary representation of either (see tmtool)
        %Cannot pass a complex variable (eg, struct, cell array)
        
        datastr=fscanf(instr_udpobj); %Read data sent by Instrument
        read_input=textscan(datastr,formatStr); %Parse string to cell-array of varibles.
        
    case 'write'
        %Send a command to satb_instrument.
        %'instrument' input parameter = Instrument's udp-object (output of satb_monitor('init',) command).
        %Can be number/vector (fwrite), text (fprintf), binary representation of either(see tmtool).
        %Cannot simply pass a complex variable (eg, struct, cell array)
        
        command='This is a message from an satb_monitor.';
        fprintf(instr_udpobj,command);
        %command %uncomment to print 
        
    case 'close'
        %End the monitor session.
        %'instrument' input parameter = Instrument's udp-object (output of satb_monitor('init',) command).
        %Can be re-'init'ed without having to restart satb_instrument.
        fclose(instr_udpobj); %Disconnect the UDP object from the host.
        disp(strcat(['Closed connection to ',instr_udpobj.name]))
        delete(instr_udpobj); %Remove object from memory (invalidated, not cleared).
        clear('instr_udpobj'); %Clear from memory.
        
end %switch

end %main fn (event loop)