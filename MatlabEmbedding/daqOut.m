function daqTime = daqOut(daq, data)
%
% daqOut writes data to DAQ with device index daq and returns time.
%
% Input: device index, data to send
% Output: time
%
% Lukas Kunz, 2023

if daq
    DaqDOut(daq, 0, data); % device index, port, data
    daqTime = GetSecs(); % current time
    DaqDOut(daq, 0, 0); % reset data sent to port
else
    daqTime = GetSecs();
    fprintf(1, '-> %d\n', data);
end