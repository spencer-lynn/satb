function uddobj=init_dioport(port,ID,hlines,direction)
% SAtb function: init_dioport: Creates an interface DIO object to, eg, the computer's LPT parallel (printer port) port.
% Example useage: parallel_port_obj=init_dio('parallel','LPT1',0:7,'out')
% Uses MatLab's Data Acquisition Toolbox <http://www.mathworks.com/help/toolbox/daq/daq.html>
%
% Uses Matlab's Data Acquisition Toolbox. May not function on MacOS.
% See Signals Approach Toolbox function trigger_demo.m for more.
% Contact Spencer Lynn, spencer.lynn@gmail.com, with questions.
% 
% 3/17/14 - With move to WIN7, DAQ tb will not use the parallel port adaptor in some configurations.
% In Win7 32-bit, try telling Windows to run Matlab "as administrator". 
% 
% The following hint is from the Psychtoolbox Yahoo user group:
% MATLAB Data Acquisition Toolbox (see 'parallel port characteristics' under 'line and port characteristics')
% Cris Niell of Stryker lab found that matlab's public digitalio methods putvalue/getvalue can be accelerated
% from ~1ms to ~20us by caching out the value of daqgetfield(dio,'uddobject'):
%1. dio = digitalio('parallel')
%2. addline(dio,7,0,'out')   %pin 9 (of 25)
%3. putvalue(dio,1)          %~700us
%4. putvalue(dio.Line,1)    %~150us
%5. uddobj = daqgetfield(dio,'uddobject')
%6. putvalue(uddobj,1,1); %~20us (undocumented use demo in @dioline\putvalue.m and @digitalio\putvalue.m - args are: uddobj, vals [, lineInds])
%7. getvalue(uddobj,1);    %~20us (undocumented use demo in @dioline\getvalue.m and @digitalio\getvalue.m - args are: uddobj [, lineInds])
%
%SKL: And, for more re Matlab DAQ-tb vs Psychtoolbox DAQ-tb vs PortTalk-tb,see:
% http://tech.groups.yahoo.com/group/psychtoolbox/message/9158
% 
% To do:
% Need to switch to PTB's IOPort fn for use in Linux.

try
    dio_obj=digitalio(port,ID) % create a digital in/out object with which you can control the parallel port LPT1
    hline=addline(dio_obj,hlines,direction) % add a hardware lines (ie,pins/bits) to the DIO object
    uddobj = daqgetfield(dio_obj,'uddobject') %Cris Niell's speed-boost by referencing cached uddobj rather than DIO itself.
    putvalue(uddobj,0) %init port to OFF.
catch DIOerror
    uddobj='NaN';
    warning(DIOerror.message)
    disp('Event triggers cannot be sent.')
    disp('Could not establish DIO object in fn: init_dioport.')
    disp('Try telling Windows 7 to run Matlab As Administrator.')
    disp('Is Data Acquisition Toolbox present?')
end
end %fn
