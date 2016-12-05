function satb_instrument(fn)
% In case of fopen errors, run tmtool and disconnect any open UDP Interface Objects.

persistent monitor_udpobj

switch fn
    case 'init'
        udp_info=instrhwinfo('udp');
        instr_ipaddy=udp_info.LocalHost(1); %needs regexp
        instr_ipaddy='192.168.1.106';
        instr_port=9090;
        
        monitor_ipaddy='192.168.1.104';
        monitor_ipaddy='spencer-mbp2'
        monitor_port=9090;
        monitor_udpobj = udp(monitor_ipaddy,'RemotePort',monitor_port,'LocalPort',instr_port)
        fopen(monitor_udpobj);
      
    case 'read'
        fscanf(monitor_udpobj)

    case 'write'
        formatStr = '%s\t%i\t%i\t%s\n';

        studyname='otd';
        trialnum=1;
        stimvalue=11;
        stimname='stim11';

        dataout={studyname ...
            trialnum ...
            stimvalue ...
            stimname};
        
        dataout
  
    % fprintf(monitor_udpobj,formatStr,dataout{1,:}); %Generates format error...
    datastr=sprintf(formatStr,dataout{1,:}); %...so convert to string, then...
    fprintf(monitor_udpobj,datastr) %send the trial's data to the Monitor.
            
    case 'close'
        fclose(monitor_udpobj)
        delete(monitor_udpobj)
        clear monitor_udpobj
        %clear ipA portA ipB portB udpB notes
        
end
end