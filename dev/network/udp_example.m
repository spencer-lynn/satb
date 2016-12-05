function udp_example
% Questions:
% is use of echo letting me pretend to send/receive?
% how to send? just fwrite/fprintf?
% how to receiver? just fread/fscanf?
% - not clear to me which of this is server vs receiver side.

%- How does the rhost/"instrument" itself read/write this (it's?) object, 
% that I've created locally, on my client?
% - How do I create a local instrument on STIM that I can read from ACQ?
% - Could create expt as generic driver instrument, use SCPI cmds to query it?
% = or perhaps the UDP object created on one machine can be accessed by another?

%Here's the answer:
% web http://www.mathworks.com/support/solutions/en/data/1-OUCYT/index.html?solution=1-OUCYT -browser

%see instrhelp('udp')

clc
port=9090; %default UDP port=9090. 4012 seems to commonly used in examples.
echoudp('on',port) %Start the echo server. Port is required.

%% Create a UDP object, associated with a host.
%I think this may establish connection to an instrument (server/remote host).
udpobj = udp('127.0.0.1',port) %port is optional->will use default 9090.


%% Open the object for writing/reading 
%I've seen this variously commented as:
%- Connect the UDP object to the host.
%- Connect to the instrument/object. 
fopen(udpobj); 

%% Write data to (rhost's?) object 
%Can be number (fwrite), text (fprintf), binary (see tmtool)
%- but how does the rhost itself read/write this object?
fwrite(udpobj,65:74) %Write numeric data to the host. Could be a query.

%% Read data from (rhost's?) object
%Can be number (fread), text (fscanf), binary? (see tmtool)
A = fread(udpobj,10) % Read from the host. Could be answer to query.

%% Clean up
fclose(udpobj); %Disconnect the UDP object from the host.
delete(udpobj); %Remove object from memory (invalidated, not cleared). Should be used at the end of an instrument session
echoudp('off') %Stop the echo server

%String-data example (from help echoudp)
echoudp('on', port);
udpobj = udp('localhost', port)
fopen(udpobj);
fprintf(udpobj, 'echo this string.');
data = fscanf(udpobj)
fclose(udpobj);
delete(udpobj);
echoudp('off');



% %Binary-data example
% % - gak: can't pass a complex variable; must be number/string.
% echoudp('on', port);
% udpobj = udp('localhost', port)
% fopen(udpobj);
% bindata={'one' 'two'};
% binblockwrite(udpobj, bindata); %CRASHES
% data = binblockread(udpobj)
% fclose(udpobj);
% delete(udpobj);
% echoudp('off');

end