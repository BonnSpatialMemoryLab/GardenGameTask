function daq = daqInit()
%
% daqInit initiates DAQ.
%
% Input: none
% Output: device index (or 0 if error).
%
% Lukas Kunz, 2023.

% try to initiate DAQ
try
    daq = DaqFind; % obtain device index
    DaqDConfigPort(daq, 0, 0); % set up port A for output (daq index, port A, output)
catch
    err = psychlasterror;
    warning('effort:daq_error', 'DAQ not found: %s', err.message);
    daq = 0;
    input('Hit Enter to continue without DAQ ...');
end