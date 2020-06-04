

% create TCPIP objects for each Hyper Deck
% TODO: this shouldn't be hard coded!!
isiKinstreamSocket = tcpip('192.168.10.70',9993);

% open both hyperdeck TCPIP channels
fopen(isiKinstreamSocket);

if(~strcmp(isiKinstreamSocket.status,'open'))
    error('Error opening TCP/IP channel to ISI Kinematics Machine.');
end

% flush input and output buffers
flushinput(isiKinstreamSocket);
flushoutput(isiKinstreamSocket);

% start recording
fprintf(isiKinstreamSocket,'recorder');
pause(1);
fprintf(isiKinstreamSocket,'ninja');
pause(1);
fprintf(isiKinstreamSocket,'record');
% close connection
fclose(isiKinstreamSocket);

