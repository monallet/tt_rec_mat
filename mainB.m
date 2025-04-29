%% mainB.m

% The script controls the equipments in one Booth (preferabally B).
% It is basically identical to the mainA.m while most of the recording calls were removed, as all the audio and EEG recordings will take place on the PC for Booth A.

% This script implements the whole experiment in sequential modal:
% (Documentation of the detailed experiment procedures can be found as README.md)
% Author: [Moana Chen]
% Date: [29.04.2025]

close all;
clear;
clc;
home;

%% experiment path load
addpath("Booth02/")
addpath("Data/")
addpath("EEG_Module/")
addpath("Eyelink_Module/")
addpath("Audio_Module/")

%% lead to saving directory
targetDir = 'C:\Data\P142-Iliopoulos\Experiment\parallelMain\Data\Data';
noiseLogDir = 'C:\Data\P142-Iliopoulos\Experiment\parallelMain\Data\noiseLog'; 

% Check if the directory exists, and if not, create it
if ~exist(targetDir, 'dir')
    mkdir(targetDir);  
end
if ~exist(noiseLogDir, 'dir')
    mkdir(noiseLogDir);  
end

% Start parallel pool with 2 workers (if not already started manually)
if isempty(gcp('nocreate'))
    parpool(2);
end

try 
    %% load participant identifier
    fprintf('Login participant data...\n');
    try
        identifierInput;
        fprintf('Login participant completed successfully.\n');
    catch ME  
        fprintf('Error during identifierInput: %s\n', ME.message);
        close all;
    end
    
    %% initialise eeg and eyelink
    trigger_port = config_io();      % Is necessary to send triggers to EEG
    initialiseEyelink; % initialise eyelink recording

    % %% initialise EEG recording (instead we manage to do manual recording)
    % write(t, nf_start); % start BEE Lab recording
    % WaitSecs(3);        % BEE Lab needs some time to start recording ...
    
    %% setup window
    % retrieve all screens
    screens = Screen('Screens'); 

    mainScreen = screens(1); 
    % externalScreen = screens(3); 

    % open a window on each screen 
    [winMain, rectMain] = PsychImaging('OpenWindow', mainScreen, WhiteIndex(mainScreen));

    Screen('TextSize', winMain, 24);

    whiteMain = BlackIndex(mainScreen); % change the background colour
    
    %% setup cam
    cam2 = webcam("HD Pro Webcam C920");

    %% break %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    %% %%%%%%%%%%%%%%%%%%% Measurement starts here    

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    %% priorRestingState measurement
    phaseID = 1;
    eyeCalib;
    calibrationStatus = waitForCalibrationAcceptance();
    if strcmp(calibrationStatus, 'accepted')
        disp('Calibration done.');
        WaitSecs(0.1);
    else
        disp('Calibration failed.');
    end

    eyeSave(targetDir, experimentID, phaseID);
    Eyelink('StartRecording');

    fprintf('Starting priorRestingState measurement...\n');
    try
        priorRestingState;
        fprintf('priorRestingState measurement completed successfully.\n');
    catch ME
        fprintf('Error during priorRestingState: %s\n', ME.message);
    end

    WaitSecs(1.0);
    Eyelink('StopRecording');
    disp('Eyelink recording saved.');
    WaitSecs(1.0)

    %% TurnTakingInduction block
    phaseID = 2;
    eyeCalib;
    calibrationStatus = waitForCalibrationAcceptance();
    if strcmp(calibrationStatus, 'accepted')
        disp('Calibration done.');
        WaitSecs(0.1);
    else
        disp('Calibration failed.');
    end

    eyeSave(targetDir, experimentID, phaseID);
    Eyelink('StartRecording');
    
    fprintf('Starting TurnTakingInduction block A...\n');
    try
        TurnTakingInductionA;
        fprintf('TurnTakingInduction block A completed successfully.\n');
    catch ME  
        fprintf('Error during TurnTakingInductionA: %s\n', ME.message);
    end
    
    fprintf('Starting TurnTakingInduction block B...\n');
    try
        TurnTakingInductionB;
        fprintf('TurnTakingInduction block B completed successfully.\n');
    catch ME  
        fprintf('Error during TurnTakingInductionB: %s\n', ME.message);
    end
    
    fprintf('Starting TurnTakingInduction block C...\n');
    try
        TurnTakingInductionC;
        fprintf('TurnTakingInduction block C completed successfully.\n');
    catch ME  
        fprintf('Error during TurnTakingInductionC: %s\n', ME.message);
    end
    
    WaitSecs(1.0);
    Eyelink('StopRecording');
    disp('Eyelink recording saved.');
    WaitSecs(1.0);

    %% NaturConv block
    phaseID = 3;
    eyeCalib; % the first calibration for the NaturConv block
    calibrationStatus = waitForCalibrationAcceptance();
    if strcmp(calibrationStatus, 'accepted')
        disp('Calibration done.');
        WaitSecs(0.1);
    else
        disp('Calibration failed.');
    end

    eyeSave(targetDir, experimentID, phaseID);
    Eyelink('StartRecording');

    fprintf('Starting NaturConv block...\n');
    try
        NaturConv;
        fprintf('NaturConv block completed successfully.\n');
    catch ME
        fprintf('Error during NaturConv: %s\n', ME.message);
    end
    
    WaitSecs(1.0);
    Eyelink('StopRecording');
    disp('Eyelink recording saved.');
    WaitSecs(1.0);

    %% convInNoise block
    phaseID = 4;
    eyeCalib;
    calibrationStatus = waitForCalibrationAcceptance();
    if strcmp(calibrationStatus, 'accepted')
        disp('Calibration done.');
        WaitSecs(0.1);
    else
        disp('Calibration failed.');
    end

    eyeSave(targetDir, experimentID, phaseID);
    Eyelink('StartRecording');

    fprintf('Starting convInNoise block...\n');
    try
        convInNoise;
        fprintf('convInNoise block completed successfully.\n');
    catch ME
        fprintf('Error during convInNoise: %s\n', ME.message);
    end
    
    WaitSecs(1.0);
    Eyelink('StopRecording');
    disp('Eyelink recording saved.');
    WaitSecs(1.0);

    %% SelfEval block
    fprintf('Starting Self Evaluation block...\n');
    try
        SelfEvalDual;
        % SelfEvalDualP; % the script adding the pausing function (not compatible)
        fprintf('Self Evaluation block completed successfully.\n');
    catch ME
        fprintf('Error during Self Evaluation: %s\n', ME.message);
    end     
    
    %% posteriorRestingState measurement
    phaseID = 5;
    eyeCalib;
    calibrationStatus = waitForCalibrationAcceptance();
    if strcmp(calibrationStatus, 'accepted')
        disp('Calibration done.');
        WaitSecs(0.1);
    else
        disp('Calibration failed.');
    end

    eyeSave(targetDir, experimentID, phaseID);
    Eyelink('StartRecording');

    fprintf('Starting posteriorRestingState measurement...\n');
    try
        posteriorRestingState; 
        fprintf('posteriorRestingState measurement completed successfully.\n');
    catch ME
        fprintf('Error during posteriorRestingState: %s\n', ME.message);
    end
    
    WaitSecs(1.0);
    Eyelink('StopRecording');
    disp('Eyelink recording saved.');
    WaitSecs(1.0);

    %% Questionnaire block
    fprintf('Starting Questionnair collection...\n');
    try 
        Questionnair;
        fprintf('Questionnair collection completed successfully.\n');
    catch ME
        fprintf('Error during Questionnair: %s\n', ME.message);
    end

    %% [for any individual function tests]
    % measurementconvDuration = 30; % seconds (for testing)
    % totalDuration = measurementconvDuration;
    % numCycleEvents = 6;
    % noiseFile = 'pink_noise_44k1.wav';
    % % 
    % % parfor i = 1:numCycleEvents
    % %     noiseRandnPTB(totalDuration, 1, experimentID, playDeviceID1, playDeviceID2, noiseLogDir, noiseFile);
    % % end
    % noiseFuture = parfeval(@noiseRandnPTB, 0, totalDuration, numCycleEvents, experimentID, playDeviceID1, playDeviceID2, noiseLogDir, noiseFile);
    % %
    % % noiseTimer = timer('StartDelay', 0, 'TimerFcn', @(~,~) parfeval(@noiseRandnPTB, 0, totalDuration, numCycleEvents, experimentID, playDeviceID1, playDeviceID2, noiseLogDir, noiseFile));
    % % start(noiseTimer);
    % % noiseRandnPTB(totalDuration, numCycleEvents, experimentID, playDeviceID1, playDeviceID2, noiseLogDir, noiseFile);
    % wait(noiseFuture)
    % % % KbWaitForShift();

    %% Close the experiment window
    KbWaitForShift();
    Screen('CloseAll');
    clear;
    close all;
    
catch ME
    sca
    Screen('CloseAll')
    rethrow(ME)
end

sca
