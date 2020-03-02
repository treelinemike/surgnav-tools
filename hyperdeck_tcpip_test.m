%% restart
close all; clear; clc;

% close all files and connections
fclose('all');

% create TCPIP objects for each Hyper Deck
% TODO: this shouldn't be hard coded!!
hyperDeckLeftIP = '192.168.10.50';
hyperDeckRightIP = '192.168.10.60';

% first see if ports alive
if(isAlive(hyperDeckLeftIP) == 1)
    disp('Left Hyperdeck Ready');
else
    warning('Left Hyperdeck NOT Ready!');
end
if(isAlive(hyperDeckRightIP) == 1)
    disp('Right Hyperdeck Ready');
else
    warning('Right Hyperdeck NOT Ready!');
end

% create serial objects
hyperDeckLeft = tcpip(hyperDeckLeftIP,9993,'Timeout',0.1);
hyperDeckRight = tcpip(hyperDeckRightIP,9993,'Timeout',0.1);

% open both hyperdeck TCPIP channels
fopen(hyperDeckLeft);
fopen(hyperDeckRight);
if(~strcmp(hyperDeckLeft.status,'open'))
    error('Error opening LEFT HyperDeck TCP/IP channel.');
end
if(~strcmp(hyperDeckRight.status,'open'))
    error('Error opening RIGHT HyperDeck TCP/IP channel.');
end
%%
% flush input and output buffers
flushinput(hyperDeckLeft);
flushoutput(hyperDeckLeft);
flushinput(hyperDeckRight);
flushoutput(hyperDeckRight);

% start recording on both Hyper Decks
% Note: \n seems to work in MATLAB on windows, need \r\n in python
fprintf(hyperDeckLeft,'ping\n');
fprintf(hyperDeckRight,'ping\n');
respL = fgets(hyperDeckLeft);
respR = fgets(hyperDeckRight);
errorVec = zeros(1,2);
if(isempty(respL) || ~strcmp(respL(1:6),'200 ok'))
    errorVec(1) = 1;
end
if(isempty(respR) || ~strcmp(respR(1:6),'200 ok'))
    errorVec(2) = 1;
end
if(prod(errorVec))
    error('Comms issue!');
end

fprintf(hyperDeckLeft,'remote: enable: true\n');
fprintf(hyperDeckRight,'remote: enable: true\n');
respL = fgets(hyperDeckLeft);
respR = fgets(hyperDeckRight);
strtrim(char(respL))
strtrim(char(respR))

fprintf(hyperDeckLeft,'slot select: slot id: 1\n');
fprintf(hyperDeckRight,'slot select: slot id: 1\n');
respL = fgets(hyperDeckLeft);
respR = fgets(hyperDeckRight);
strtrim(char(respL))
strtrim(char(respR))


fprintf(hyperDeckLeft,'record\n');
fprintf(hyperDeckRight,'record\n');
respL = fgets(hyperDeckLeft);
respR = fgets(hyperDeckRight);
strtrim(char(respL))
strtrim(char(respR))
%%
fclose(hyperDeckLeft);  
fclose(hyperDeckRight);


function status = isAlive(ipAddr,timeout)
    [sysStatus,sysOut] = system(['ping -n 1 -w 10 ' ipAddr ' | grep ''% loss'' | sed ''s/.*(\(.*\)\% loss),/\1/''']);
    if(str2num(sysOut) == 0)
        status = 1;
    else
        status = 0;
    end
 end



