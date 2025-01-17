%==========================================================================
% This script starts the Garden Game and sends triggers to both the Garden
% Game and to the data acquisition (DAQ) device to log these triggers in
% the electrophysiological data.
%
% Notes:
% - Psychtoolbox has to be installed.
% - If you get an error message that the DAQ is not connected, restart
%   Matlab.
% - Using the joystick/gamepad requires that Simulink 3D Animation is
%   installed (not regularly included in Matlab).
%
% Lukas Kunz, 2023/08/13.
%==========================================================================

% start
clear; clc; close all;
format long g;
format compact;

% Predator Sense: double-check whether you have switched it on
waitfor(msgbox('Did you switch on PredatorSense?'));

% paths
paths           = [];
paths.matlab    = strcat(fileparts(matlab.desktop.editor.getActiveFilename), '\'); % path of matlab embedding
paths.save      = strcat(paths.matlab, 'TriggerTiming\');
if ~exist(paths.save, 'dir')
    mkdir(paths.save);
end
addpath(paths.matlab);
cd(paths.matlab);

% select exe file of Garden Game
[GGFile, GGPath]        = uigetfile('*GardenGame.exe', 'SELECT THE GARDEN GAME FILE (example: C:\BSML\GardenGame\BSML_GardenGame_***\GardenGame.exe)');

% settings
param                   = [];
param.GGFile            = fullfile(GGPath, GGFile);
param.trigData          = 1; % trigger data to send to the ATLAS system
param.numInitTriggers   = 10; % number of initial triggers
param.numFinalTriggers  = 20; % number of final triggers
param.ITIDuration       = [2, 4]; % range for random inter-trigger intervals
param.inputDevice       = 'gamepad'; % gamepad | keyboard

% current date and time
clockTime = datevec(datetime('now', 'Format', 'yyyy-MM-dd HH:mm:ss.SSS'));

% report
fprintf('======================================================================================\n');
fprintf('MATLAB EMBEDDING FOR RUNNING THE GARDEN GAME.\n');
fprintf('Garden Game: "%s".\n', param.GGFile);
fprintf('Trigger data to send to DAQ: %d.\n', param.trigData);
fprintf('Input device for starting the triggers: %s.\n', param.inputDevice);
fprintf('Current date and time: %d/%d/%d, %d:%d:%.3f.\n', clockTime);
fprintf('======================================================================================\n\n');

%% psychtoolbox for timing
% if there are timing problems so that you cannot proceed, use:
% Screen('Preference', 'SkipSyncTests', 1);
% to force PTB to continue despite potential timing problems
% however, overclocking the experiment laptop should solve any timing
% problems

% start psychtoolbox with default settings
PsychDefaultSetup(2);

%% joystick

% initiate joystick
if strcmp(param.inputDevice, 'gamepad')
    joy = vrjoystick(1); % this requires Simulink 3D Animation
end

%% DAQ

% initiate DAQ
daq = daqInit;

%% send initial trigger burst to DAQ
% these triggers are only visible in the electrophysiological data but not
% in the behavioral data

% indicate start of experiment
for i = 1:param.numInitTriggers
    daqOut(daq, param.trigData); % send trigger to amplifier
    WaitSecs(0.5); % wait some time between subsequent triggers
end

%% set up robot to simulate button presses, which will provide triggers for the paradigm

% initialise java
robot = java.awt.Robot;
WaitSecs(5); % give some time for java to start

%% start Garden Game

% report
fprintf('\nStarting the Garden Game and waiting for first player action:\n');

% use Matlab to start the Garden Game
command = strcat('"', param.GGFile, '" &');
system(command);

% wait until first subject input (should occur when the subject starts the
% first trial, for example by pressing a button on the gamepad)
bInput = false;
if strcmp(param.inputDevice, 'gamepad')
    while ~bInput
        buttonInput = button(joy);
        if any(buttonInput) % if the subject presses any button on the gamepad
            bInput = true;
            fprintf('Any button of the gamepad has been pressed.\n');
        end
    end
elseif strcmp(param.inputDevice, 'keyboard')
    while ~bInput
        [keyIsDown, ~, keyCode] = KbCheck;
        if keyIsDown && keyCode(KbName('x')) % if the subject presses X on the keyboard
            bInput = true;
            fprintf('Keyboard X has been pressed.\n');
        end
    end
end

% check whether task is running
[~, result] = system('tasklist /FI "imagename eq GardenGame.exe" /nh');
if contains(result, 'No task')
    error('Garden Game is not running.');
else
    % indicate that the task is running
    bTaskRunning = true;
end

%% send triggers

% report
fprintf('\nStarting MATLAB triggering:\n');

% text file for logging trigger times in matlab
fid = fopen(sprintf('%sGardenGame_TriggerTimesInMatlab_%d_%d_%d_%d_%d_%.0f.txt', ...
    paths.save, clockTime(1), clockTime(2), clockTime(3), clockTime(4), clockTime(5), 1000 * clockTime(6)), 'w');

% trigger index
triggerIdx = 0;

% send triggers while the paradigm is running
while bTaskRunning == true
    
    % increase trigger index and report
    triggerIdx = triggerIdx + 1;
    if mod(triggerIdx, 100) == 1
        fprintf('Trigger index: %d.\n', triggerIdx);
    end
    
    % preallocate matlab trigger times (before behavioral trigger; after
    % behavioral trigger; after ephys trigger; after eyetracker trigger;
    % after behavioral backup trigger)
    matlabTriggerTime = nan(1, 5);
    matlabClockTime = cell(1, 5);

    % matlab-time immediately before sending the behavioral trigger
    matlabTriggerTime(1, 1) = GetSecs;
    matlabClockTime{1, 1} = char(datetime('now', 'Format', 'yyyy-MM-dd HH:mm:ss.SSS'));
    
    % send trigger to Garden Game (by simulating that "T" is pressed)
    robot.keyPress(java.awt.event.KeyEvent.VK_T);
    robot.keyRelease(java.awt.event.KeyEvent.VK_T);
    
    % matlab-time after sending the behavioral trigger
    matlabTriggerTime(1, 2) = GetSecs;
    matlabClockTime{1, 2} = char(datetime('now', 'Format', 'yyyy-MM-dd HH:mm:ss.SSS'));
        
    % send trigger to amplifier
    daqOut(daq, param.trigData);
    
    % matlab-time after sending the ephys trigger
    matlabTriggerTime(1, 3) = GetSecs;
    matlabClockTime{1, 3} = char(datetime('now', 'Format', 'yyyy-MM-dd HH:mm:ss.SSS'));
    
    % send trigger to eyetracker (needs to be implemented)
    
    % matlab-time after the eyetracker trigger
    matlabTriggerTime(1, 4) = GetSecs;
    matlabClockTime{1, 4} = char(datetime('now', 'Format', 'yyyy-MM-dd HH:mm:ss.SSS'));
    
    % wait for 50 milliseconds so that the behavioral backup trigger does
    % not occur during the same frame as the real trigger
    WaitSecs(0.05);

    % send backup trigger to Garden Game (by simulating that "R" is pressed)
    robot.keyPress(java.awt.event.KeyEvent.VK_R);
    robot.keyRelease(java.awt.event.KeyEvent.VK_R);

    % matlab time after sending the behavioral backup trigger
    matlabTriggerTime(1, 5) = GetSecs;
    matlabClockTime{1, 5} = char(datetime('now', 'Format', 'yyyy-MM-dd HH:mm:ss.SSS'));
    
    % write to text file
    fprintf(fid, '%d, %.6f, %.6f, %.6f, %.6f, %.6f, %s, %s, %s, %s, %s\n', triggerIdx, matlabTriggerTime(1, :), matlabClockTime{1, :});
    
	% next inter-trigger interval
    ITI = unifrnd(min(param.ITIDuration), max(param.ITIDuration));
    if mod(triggerIdx, 3) == 1
        ITI = 1;
    end
	WaitSecs(ITI);
    
    % check whether paradigm is still running
    [~, result] = system('tasklist /FI "imagename eq GardenGame.exe" /nh');
    if contains(result, 'No task')
        bTaskRunning = false;
        fprintf('\nTask not running.\n');
    end
end

%% send final trigger burst to DAQ
% these triggers are only visible in the electrophysiological data but not 
% in the behavioral data

% indicate end of experiment
for i = 1:param.numFinalTriggers
    daqOut(daq, param.trigData); % send trigger to amplifier
    WaitSecs(0.5); % wait some time between subsequent triggers
end

%% close everything

% close the matlab trigger file
fclose all;

% deactivate java
clear robot;

% report
fprintf('\nMatlab embedding ended.');
fprintf('======================================================================================\n');

%% END