%==========================================================================
% This script creates the configuration files for the Garden Game.
%
% Encoding: two paths
%   - Player starts at random location with random orientation.
%   - Player navigates to stable/unstable object.
%   - Player navigates to unstable/stable object.
% Egocentric retrieval: two retrievals
%   - Player starts at random location.
%   - Player responds at remembered egocentric location of the object.
% Allocentric retrieval: two retrievals
%   - Player starts at random location.
%   - Player responds at remembered allocentric location of the object.
%
% Important notes:
%   - Adjust the "paths.save" variable to save the configuration files in
%   the correct directory of the source Unity project. Afterward, build the
%   project using File -> Build Settings -> Build in Unity. Play the game
%   with an example subject to see whether the correct configuration files
%   are used.
%   - Adjust the "paths.functions" variable to be able to use the functions
%   for plotting some sanity-check figures.
%
% Lukas Kunz, 2025
%==========================================================================

% start
clear; close all; clc;

% paths
paths           = [];
paths.save      = "C:\BSML\GardenGame\BSML_GardenGameWithEyeTracking_20m_20231201\Assets\StreamingAssets\Config\"; % Unity project folder
paths.figures   = strcat(paths.save, 'Figures\');
paths.functions = "C:\GitCode\Functions\"; % for random locations in a circle (starting positions during egocentric retrieval)
addpath(paths.functions);

% create output folders
if ~exist(paths.save, 'dir')
    mkdir(paths.save);
end
if ~exist(paths.figures, 'dir')
    mkdir(paths.figures);
end

% settings
param                       = [];
param.numSubjects           = 999; % number of subjects to produce
param.numTrials             = 60; % number of trials per session
param.numObjects            = 6; % number of objects per session
param.numPracticeObjects    = 2; % number of objects for the practice trial
param.numStableObjects      = 3; % number of stable objects per session
param.numUnstableObjects    = param.numObjects - param.numStableObjects; % there should be an identical number of stable and unstable objects
param.numObjPerTrial        = 2; % number of different objects per trial
param.numTrees              = 3; % number of trees
param.scoreFreq             = 4; % frequency of showing the score (every n trials)
param.arena.ctr             = [0, 0]; % center of the arena
param.arena.edgeLength      = 20; % arena edge length
param.arena.xLim            = [-param.arena.edgeLength / 2, param.arena.edgeLength / 2]; % x-limits of the arena
param.arena.zLim            = [-param.arena.edgeLength / 2, param.arena.edgeLength / 2]; % z-limits of the arena
param.player.xRange         = [-9, 9]; % range for possible start x-locations of the player
param.player.zRange         = [-9, 9]; % range for possible start z-locations of the player
param.player.minD2Obj       = 5; % minimum distance between player start position and trial-specific objects
param.player.maxD2Obj       = param.arena.edgeLength; % maximum distance between player start position and trial-specific objects
param.player.minD2Tree      = 1; % minimum distance between player start position and trees
param.tree.xRange           = [-5.1, -4.9; 4.9, 5.1]; % possible tree x-locations
param.tree.zRange           = [-5.1, -4.9; 4.9, 5.1]; % possible tree z-locations
param.obj.name              = ["Bird"; "Camel"; "Cat"; "Chicken"; "Dog"; "Elephant"; "Horse"; ...
    "Leopard"; "Penguin"; "Pig"; "Pug"; "Rhino"; "Sheep"; "Tiger"]; % object names
param.obj.name4Ret          = ["the bird"; "the camel"; "the cat"; "the chicken"; "the dog"; "the elephant"; "the horse"; ...
    "the leopard"; "the penguin"; "the pig"; "the pug"; "the rhino"; "the sheep"; "the tiger"]; % object names for retrieval
param.obj.nameGER           = ["Vogel"; "Kamel"; "Katze"; "Küken"; "Hund"; "Elefant"; "Pferd"; ...
    "Leopard"; "Pinguin"; "Schwein"; "Mops"; "Nashorn"; "Schaf"; "Tiger"]; % object names in German
param.obj.nameGER4Ret       = ["der Vogel"; "das Kamel"; "die Katze"; "das Küken"; "der Hund"; "der Elefant"; "das Pferd"; ...
    "der Leopard"; "der Pinguin"; "das Schwein"; "der Mops"; "das Nashorn"; "das Schaf"; "der Tiger"]; % object names in German for retrieval
param.obj.xRange            = [-8.5, 8.5];
param.obj.zRange            = [-8.5, 8.5];
param.obj.minD2Tree         = 1.5; % minimum distance of objects to a tree
param.obj.st.angleEdges     = transpose(deg2rad(-180:(360/param.numObjects):180));
param.obj.st.angleMeans     = movmean(param.obj.st.angleEdges, 2, 'Endpoints', 'discard');
param.obj.st.angleIdx       = transpose(1:size(param.obj.st.angleMeans, 1));
param.obj.st.minD2Obj       = 10; % minimum distance of stable objects to other stable objects
param.obj.st.xJitter        = [-1, 1]; % spatial jitter of stable object locations (x axis)
param.obj.st.zJitter        = [-1, 1]; % spatial jitter of stable object locations (z axis)
param.obj.st.minD2Ctr       = 5; % minimum distance of stable object locations to the center
param.obj.unst.minD2Obj     = 10; % minimum distance of unstable objects to other objects from the same trial
param.obj.unst.minD2AllObj  = 1; % minimum distance of unstable objects to all other objects
param.egoRet.circleFarRad   = 10; % radius of far circle during egocentric retrieval (based on settings in Unity)

%% loop through subjects
for iSub = 1:param.numSubjects
    
    % set rng for reproducibility
    rng(iSub);

    % subject-specific configuration files for saving
    subjTrialFile   = strcat(paths.save, "Subject", sprintf('%d', iSub), "_TrialConfig.txt");
    subjTreeFile    = strcat(paths.save, "Subject", sprintf('%d', iSub), "_TreeConfig.txt");

    %% tree configuration
    
    % one random location in each tree area
    treeXZ = nan(4, 2);
    for iX = 1:size(param.tree.xRange, 1)
        for iZ = 1:size(param.tree.zRange, 1)
            i = (iX - 1) * size(param.tree.zRange, 1) + iZ;
            treeXZ(i, :) = [unifrnd(param.tree.xRange(iX, 1), param.tree.xRange(iX, 2)), unifrnd(param.tree.zRange(iZ, 1), param.tree.zRange(iZ, 2))]; 
        end
    end
    
    % reduce the number of locations to the number of trees
    treeIdx = sort(datasample(1:size(treeXZ, 1), param.numTrees, 'replace', false));
    treeXZ = round(treeXZ(treeIdx, :), 1);

    % write tree configuration file
    fid = fopen(subjTreeFile, 'w');
    for iTree = 1:size(treeXZ, 1)
        fprintf(fid, 'Tree%d,%.1f,%.1f,%.1f\n', iTree - 1, treeXZ(iTree, 1), 0, treeXZ(iTree, 2));
    end
    fclose(fid);

    % report
    fprintf("\nTree locations:\n");
    disp(treeXZ);
    fprintf("Written to: %s.\n\n", subjTreeFile);
    
    % create figure
    fcfg        = [];
    fcfg.paths  = paths;
    fcfg.param  = param;
    fcfg.treeXZ = treeXZ;
    fcfg.iSub   = iSub;
    LK_GardenGame_PlotTreeXZ_20230814(fcfg);
    
    %% trial configuration: objects
    
    % report
    fprintf('\nFinding stable and unstable objects.\n');
    
    % randomly draw n objects for this session
    objIdx      = datasample(1:size(param.obj.name, 1), param.numObjects, 'replace', false);
    objNames    = param.obj.name(objIdx); % non-alphabetically to avoid bias when selecting stable vs. unstable objects

    % stable objects and unstable objects
    stableObjNames      = objNames(1:param.numStableObjects);
    unstableObjNames    = objNames(param.numStableObjects + 1:end);

    % object sequence across the entire session (per trial, one stable
    % object and one unstable object)
    sessObjNames        = strings(param.numTrials, param.numObjPerTrial); % 60 trials x [stable object, unstable object]
    numChunks           = param.numTrials / (param.numObjects / param.numObjPerTrial); % e.g., 20 chunks
    numTrialsPerChunk   = param.numTrials / numChunks; % e.g., 3 trials per chunk
    for iChunk = 1:numChunks
        tmpObjNames         = [datasample(stableObjNames, size(stableObjNames, 1), 'replace', false), ...
            datasample(unstableObjNames, size(unstableObjNames, 1), 'replace', false)];
        i                   = ((iChunk - 1) * numTrialsPerChunk + 1):iChunk * numTrialsPerChunk;
        sessObjNames(i, :)  = tmpObjNames; % left column: stable object; right column: unstable object
    end

    % ensure that half of the trials begin with a stable object and that
    % the other half of the trials begin with an unstable object
    bFirstStable = [true(1, param.numTrials / 2); false(1, param.numTrials / 2)];
    bFirstStable = circshift(bFirstStable(:), iSub); % either stable or unstable object first
    for iTrial = 1:size(sessObjNames, 1)
        if bFirstStable(iTrial, 1) == false
            sessObjNames(iTrial, :) = fliplr(sessObjNames(iTrial, :)); % left column: stable/unstable; right column: stable/unstable
        end
    end

    % object names for retrieval and in German
    sessObjNames4Ret    = strings(size(sessObjNames));
    sessObjNamesGER     = strings(size(sessObjNames));
    sessObjNamesGER4Ret = strings(size(sessObjNames));
    for iTrial = 1:size(sessObjNames, 1)
        for iObj = 1:size(sessObjNames, 2)
            logIdx                              = sessObjNames(iTrial, iObj) == param.obj.name;
            sessObjNames4Ret(iTrial, iObj)      = param.obj.name4Ret(logIdx);
            sessObjNamesGER(iTrial, iObj)       = param.obj.nameGER(logIdx);
            sessObjNamesGER4Ret(iTrial, iObj)   = param.obj.nameGER4Ret(logIdx);
        end
    end
    
    %% trial configuration: locations of the stable objects
    % note: add a small jitter to the stable object locations on each trial
    % to increase the arena coverage
    
    % report
    fprintf('\nFinding locations for the stable objects.\n');
    
    % locations for the stable objects
    stableObjXZ = nan(param.numStableObjects, 2); % stable objects x XZ
    randNum     = datasample(1:(size(param.obj.st.angleIdx, 1) / param.numStableObjects), 1) - 1; % which angle set to use for placing the objects
    angleIdx    = transpose(randNum + (1:(size(param.obj.st.angleIdx, 1) / param.numStableObjects):size(param.obj.st.angleIdx, 1))); % which angle edges to use
    for iObj = 1:param.numStableObjects

        % create object location with specific requirements
        bUseObject = false;
        while bUseObject == false
            
            % draw random location
            thisXZ = [unifrnd(min(param.obj.xRange), max(param.obj.xRange)), unifrnd(min(param.obj.zRange), max(param.obj.zRange))];
            
            % ensure that the location is within a specific angle
            thisAngle = atan2(thisXZ(2), thisXZ(1));
            if thisAngle >= param.obj.st.angleEdges(angleIdx(iObj)) && thisAngle <= param.obj.st.angleEdges(angleIdx(iObj) + 1)
                bWithinAngle = true;
            else
                bWithinAngle = false;
            end

            % ensure that the object has a sufficient distance to the
            % other objects
            D = pdist2(thisXZ, stableObjXZ);
            if all(isnan(D))
                bSuffD2Obj = true;
            elseif all(D(~isnan(D)) > param.obj.st.minD2Obj)
                bSuffD2Obj = true;
            else
                bSuffD2Obj = false;
            end

            % ensure that the object has a sufficient distance to the trees
            D = pdist2(thisXZ, treeXZ);
            if all(D > param.obj.minD2Tree)
                bSuffD2Tree = true;
            else
                bSuffD2Tree = false;
            end

            % ensure that the object has a sufficient distance to the
            % center
            D = pdist2(thisXZ, param.arena.ctr);
            if D > param.obj.st.minD2Ctr
                bSuffD2Ctr  = true;
            else
                bSuffD2Ctr  = false;
            end

            % check all requirements
            if bWithinAngle && bSuffD2Obj && bSuffD2Tree && bSuffD2Ctr
                bUseObject = true;
                stableObjXZ(iObj, :) = thisXZ;
            else
                bUseObject = false;
            end
        end
    end
    
    % sanity check
    tmpAngle = atan2(stableObjXZ(:, 2), stableObjXZ(:, 1)); % angles of the stable objects
    tmpAngleIdx = discretize(tmpAngle, param.obj.st.angleEdges);
    if ~all(tmpAngleIdx == angleIdx)
        error("Problem with defining the stable object locations.");
    end
    
    % report
    fprintf("\nStable object locations:\n");
    disp(stableObjXZ);

    % loop through trials and fill in locations of stable objects
    sessObjXZ = cell(param.numTrials, param.numObjPerTrial); % trials x objects-per-trial
    for iTrial = 1:param.numTrials
        
        % loop through objects in this trial
        for iObj = 1:param.numObjPerTrial
        
            % if it is a stable object, use its predefined location
            if any(contains(stableObjNames, sessObjNames(iTrial, iObj)))
                sessObjXZ{iTrial, iObj} = stableObjXZ(stableObjNames == sessObjNames(iTrial, iObj), :);
            end
        end
    end

    % add a small jitter to each stable object location
    for iTrial = 1:param.numTrials
        for iObj = 1:param.numObjPerTrial
            if ~isempty(sessObjXZ{iTrial, iObj})
                sessObjXZ{iTrial, iObj} = sessObjXZ{iTrial, iObj} + [unifrnd(min(param.obj.st.xJitter), max(param.obj.st.xJitter)), ...
                    unifrnd(min(param.obj.st.zJitter), max(param.obj.st.zJitter))];
            end
        end
    end
    
    %% trial configuration: locations of unstable objects
    
    % report
    fprintf('\nFinding locations for the unstable objects.\n');
    
    % loop through trials to get locations of unstable objects
    for iTrial = 1:param.numTrials

        % report
        fprintf("... trial: %d\n", iTrial);
        
        % loop through objects in this trial
        for iObj = 1:param.numObjPerTrial

            % if it is not a stable object, create object location with
            % specific requirements
            if ~any(contains(stableObjNames, sessObjNames(iTrial, iObj)))
                
                % create specific object location with specific
                % requirements
                bUseObject = false;
                while bUseObject == false

                    % draw random location
                    thisXZ = [unifrnd(min(param.obj.xRange), max(param.obj.xRange)), ...
                        unifrnd(min(param.obj.zRange), max(param.obj.zRange))];

                    % ensure that the object has a sufficient distance to
                    % the other object in this trial
                    D = pdist2(thisXZ, cell2mat(transpose(sessObjXZ(iTrial, :)))); % empty cells are removed when using cell2mat
                    if all(D > param.obj.unst.minD2Obj)
                        bSuffD2Obj = true;
                    else
                        bSuffD2Obj = false;
                    end

                    % ensure that the object has a sufficient distance to
                    % all other objects from all trials
                    D = pdist2(thisXZ, cell2mat(sessObjXZ(:)));
                    if all(D > param.obj.unst.minD2AllObj)
                        bSuffD2AllObj = true;
                    else
                        bSuffD2AllObj = false;
                    end

                    % ensure that the object has a sufficient distance to
                    % the trees
                    D = pdist2(thisXZ, treeXZ);
                    if all(D > param.obj.minD2Tree)
                        bSuffD2Tree = true;
                    else
                        bSuffD2Tree = false;
                    end

                    % check all requirements
                    if bSuffD2Obj && bSuffD2AllObj && bSuffD2Tree
                        bUseObject = true;
                        sessObjXZ{iTrial, iObj} = thisXZ;
                    else
                        bUseObject = false;
                    end
                end
            end
        end
    end
    
    % create figure
    fcfg            = [];
    fcfg.paths      = paths;
    fcfg.param      = param;
    fcfg.sessObjXZ  = sessObjXZ;
    fcfg.iSub       = iSub;
    LK_GardenGame_PlotSessObjXZ_20230814(fcfg);
    
    %% trial configuration: player starting locations
    
    % trial-wise starting location of the player
    sessPlayerStartXZ = nan(param.numTrials, 2); % trials x XZ
    for iTrial = 1:param.numTrials
        
        % create player starting location with specific requirements
        bUseXZ = false;
        while bUseXZ == false
            
            % random starting location
            thisXZ = [unifrnd(min(param.player.xRange), max(param.player.xRange)), ...
                unifrnd(min(param.player.zRange), max(param.player.zRange))];

            % ensure that the starting location has a specific minimum
            % distance and a specific maximum distance to the objects from
            % this trial
            D = pdist2(thisXZ, cell2mat(transpose(sessObjXZ(iTrial, :))));
            if all(D > param.player.minD2Obj) && all(D <= param.player.maxD2Obj)
                bGoodD2Obj = true;
            else
                bGoodD2Obj = false;
            end

            % ensure that the starting location has a minimum distance to
            % the trees
            D = pdist2(thisXZ, treeXZ);
            if all(D > param.player.minD2Tree)
                bSuffD2Tree = true;
            else
                bSuffD2Tree = false;
            end

            % check all requirements
            if bGoodD2Obj && bSuffD2Tree
                bUseXZ = true;
                sessPlayerStartXZ(iTrial, :) = thisXZ;
            else
                bUseXZ = false;
            end
        end
    end

    % trial-wise starting yaw of the player
    sessPlayerStartYaw = transpose(0:(360/param.numTrials):(360 - 360/param.numTrials));
    sessPlayerStartYaw = datasample(sessPlayerStartYaw, numel(sessPlayerStartYaw), 'replace', false);

    % create figure showing the subject's starting locations
    fcfg                    = [];
    fcfg.param              = param;
    fcfg.paths              = paths;
    fcfg.sessPlayerStartXZ  = sessPlayerStartXZ;
    fcfg.stableObjXZ        = stableObjXZ;
    fcfg.treeXZ             = treeXZ;
    fcfg.iSub               = iSub;
    LK_GardenGame_PlotSessPlayerStartXZ_20230814(fcfg);
    
    %% trial configuration: egocentric retrieval
    
    % starting location of the response object during egocentric retrieval
    cfg                 = [];
    cfg.maxR            = param.egoRet.circleFarRad; % radius of the far circle (in Unity virtual meters; e.g., 10)
    cfg.minR            = 0;
    cfg.N               = param.numTrials * param.numObjPerTrial; % new random starting location for each object
    cfg.centerX         = 0;
    cfg.centerY         = 0;
    tmpSessEgoStartXZ   = LK_RandomPointsInCircle(cfg);

    % distribute onto trials and objects
    sessEgoStartXZ      = cell(param.numTrials, param.numObjPerTrial);
    count               = 1; % running count
    for iTrial = 1:param.numTrials
        for iObj = 1:param.numObjPerTrial
            sessEgoStartXZ{iTrial, iObj}    = tmpSessEgoStartXZ(count, :);
            count                           = count + 1;
        end
    end

    % create figure showing the starting positions during egocentric
    % retrieval
    fcfg                = [];
    fcfg.param          = param;
    fcfg.paths          = paths;
    fcfg.sessEgoStartXZ = sessEgoStartXZ;
    fcfg.iSub           = iSub;
    LK_GardenGame_PlotSessEgoStartXZ_20230814(fcfg);

    %% trial configuration: allocentric retrieval
    
    % starting location of the response object during allocentric retrieval
    sessAlloStartXZ = cell(param.numTrials, param.numObjPerTrial);
    for iTrial = 1:param.numTrials
        for iObj = 1:param.numObjPerTrial
            sessAlloStartXZ{iTrial, iObj} = [unifrnd(min(param.arena.xLim), max(param.arena.xLim), 1), ...
                unifrnd(min(param.arena.zLim), max(param.arena.zLim), 1)];
        end
    end

    % create figure showing the starting positions during allocentric
    % retrieval
    fcfg                    = [];
    fcfg.param              = param;
    fcfg.paths              = paths;
    fcfg.sessAlloStartXZ    = sessAlloStartXZ;
    fcfg.iSub               = iSub;
    LK_GardenGame_PlotSessAlloStartXZ_20230814(fcfg);

    %% trial configuration: sequence of retrievals
    % during each retrieval, there are two egocentric retrievals and two
    % allocentric retrievals

    % ensure balanced sampling of possible conditions (ego/allo, 1/2, 1/2)
    bBalanced = false;
    while bBalanced == false

        % determine whether egocentric or allocentric retrieval shall be first
        bFirstEgo   = [true(1, param.numTrials / 2); false(1, param.numTrials / 2)]; % ensure that half of the trials start with egocentric retrieval
        bFirstEgo   = circshift(bFirstEgo(:), datasample(1:numel(bFirstEgo), 1)); % alternating egocentric and allocentric retrieval first

        % determine which of the two egocentric retrievals shall be first
        bFirstEgo1  = [true(1, param.numTrials / 2); false(1, param.numTrials / 2)];
        bFirstEgo1  = datasample(bFirstEgo1(:), numel(bFirstEgo1), 'replace', false); % random sequence of which egocentric retrieval first

        % determine which of the two allocentric retrievals shall be first
        bFirstAllo1 = [true(1, param.numTrials / 2); false(1, param.numTrials / 2)];
        bFirstAllo1 = datasample(bFirstAllo1(:), numel(bFirstAllo1), 'replace', false); % random sequence of which allocentric retrieval first

        % check whether conditions are sufficiently balanced
        conditions  = [bFirstEgo, bFirstEgo1, bFirstAllo1];
        counts      = groupcounts(conditions);
        if all(counts >= 6)
            bBalanced = true;
        end
    end

    % report
    fprintf('Minimum number of trials in a given condition: %d.\n', min(counts));

    %% trial configuration

    % create configuration file
    fid = fopen(subjTrialFile, 'w');
    
    % add practice trial (index 0 indicates practice trial)
    idxUnused = find(~contains(param.obj.name, objNames)); % objects that are otherwise not used in this session
    idxUnused = datasample(idxUnused, param.numPracticeObjects, 'replace', false); % use two of the unused objects
    fprintf(fid, sprintf("0,Encoding,0,0,0,%s,%s,%s,%s,0,5\n", ...
        param.obj.name(idxUnused(1)), param.obj.name4Ret(idxUnused(1)), param.obj.nameGER(idxUnused(1)), param.obj.nameGER4Ret(idxUnused(1))));
    fprintf(fid, sprintf("0,Encoding,9999,9999,9999,%s,%s,%s,%s,-5,0\n", ...
        param.obj.name(idxUnused(2)), param.obj.name4Ret(idxUnused(2)), param.obj.nameGER(idxUnused(2)), param.obj.nameGER4Ret(idxUnused(2))));
    fprintf(fid, sprintf("0,EgocentricRetrieval,0,-5,9999,%s,%s,%s,%s,0,5\n", ...
        param.obj.name(idxUnused(1)), param.obj.name4Ret(idxUnused(1)), param.obj.nameGER(idxUnused(1)), param.obj.nameGER4Ret(idxUnused(1))));
    fprintf(fid, sprintf("0,EgocentricRetrieval,5,0,9999,%s,%s,%s,%s,-5,0\n", ...
        param.obj.name(idxUnused(2)), param.obj.name4Ret(idxUnused(2)), param.obj.nameGER(idxUnused(2)), param.obj.nameGER4Ret(idxUnused(2))));
    fprintf(fid, sprintf("0,AllocentricRetrieval,0,-5,9999,%s,%s,%s,%s,0,5\n", ...
        param.obj.name(idxUnused(1)), param.obj.name4Ret(idxUnused(1)), param.obj.nameGER(idxUnused(1)), param.obj.nameGER4Ret(idxUnused(1))));
    fprintf(fid, sprintf("0,AllocentricRetrieval,5,0,9999,%s,%s,%s,%s,-5,0\n", ...
        param.obj.name(idxUnused(2)), param.obj.name4Ret(idxUnused(2)), param.obj.nameGER(idxUnused(2)), param.obj.nameGER4Ret(idxUnused(2))));
    fprintf(fid, sprintf("0,Score,9999,9999,9999,9999,9999,9999,9999,9999,9999\n"));

    % write all trials to the trial configuration file
    for iTrial = 1:param.numTrials
    
        % encoding information
        enc1 = sprintf("%d,Encoding,%.1f,%.1f,%.1f,%s,%s,%s,%s,%.1f,%.1f", iTrial, ...
            sessPlayerStartXZ(iTrial, 1), sessPlayerStartXZ(iTrial, 2), sessPlayerStartYaw(iTrial, 1), ...
            sessObjNames(iTrial, 1), sessObjNames4Ret(iTrial, 1), sessObjNamesGER(iTrial, 1), sessObjNamesGER4Ret(iTrial, 1), ...
            sessObjXZ{iTrial, 1}(1), sessObjXZ{iTrial, 1}(2)); % first object
        enc2 = sprintf("%d,Encoding,9999,9999,9999,%s,%s,%s,%s,%.1f,%.1f", iTrial, ...
            sessObjNames(iTrial, 2), sessObjNames4Ret(iTrial, 2), sessObjNamesGER(iTrial, 2), sessObjNamesGER4Ret(iTrial, 2), ...
            sessObjXZ{iTrial, 2}(1), sessObjXZ{iTrial, 2}(2)); % second object

        % egocentric retrieval information
        ego1 = sprintf("%d,EgocentricRetrieval,%.1f,%.1f,9999,%s,%s,%s,%s,%.1f,%.1f", iTrial, ...
            sessEgoStartXZ{iTrial, 1}(1), sessEgoStartXZ{iTrial, 1}(2), ...
            sessObjNames(iTrial, 1), sessObjNames4Ret(iTrial, 1), sessObjNamesGER(iTrial, 1), sessObjNamesGER4Ret(iTrial, 1), ...
            sessObjXZ{iTrial, 1}(1), sessObjXZ{iTrial, 1}(2));
        ego2 = sprintf("%d,EgocentricRetrieval,%.1f,%.1f,9999,%s,%s,%s,%s,%.1f,%.1f", iTrial, ...
            sessEgoStartXZ{iTrial, 2}(1), sessEgoStartXZ{iTrial, 2}(2), ...
            sessObjNames(iTrial, 2), sessObjNames4Ret(iTrial, 2), sessObjNamesGER(iTrial, 2), sessObjNamesGER4Ret(iTrial, 2), ...
            sessObjXZ{iTrial, 2}(1), sessObjXZ{iTrial, 2}(2));
        ego = circshift([ego1; ego2], double(~bFirstEgo1(iTrial)));

        % allocentric retrieval information
        allo1 = sprintf("%d,AllocentricRetrieval,%.1f,%.1f,9999,%s,%s,%s,%s,%.1f,%.1f", iTrial, ...
            sessAlloStartXZ{iTrial, 1}(1), sessAlloStartXZ{iTrial, 1}(2), ...
            sessObjNames(iTrial, 1), sessObjNames4Ret(iTrial, 1), sessObjNamesGER(iTrial, 1), sessObjNamesGER4Ret(iTrial, 1), ...
            sessObjXZ{iTrial, 1}(1), sessObjXZ{iTrial, 1}(2));
        allo2 = sprintf("%d,AllocentricRetrieval,%.1f,%.1f,9999,%s,%s,%s,%s,%.1f,%.1f", iTrial, ...
            sessAlloStartXZ{iTrial, 2}(1), sessAlloStartXZ{iTrial, 2}(2), ...
            sessObjNames(iTrial, 2), sessObjNames4Ret(iTrial, 2), sessObjNamesGER(iTrial, 2), sessObjNamesGER4Ret(iTrial, 2), ...
            sessObjXZ{iTrial, 2}(1), sessObjXZ{iTrial, 2}(2));
        allo = circshift([allo1; allo2], double(~bFirstAllo1(iTrial)));

        % retrieval combined
        ret = circshift({ego; allo}, double(~bFirstEgo(iTrial)));

        % score information
        sc = sprintf("%d,Score,9999,9999,9999,9999,9999,9999,9999,9999,9999", iTrial);

        % write information to txt file
        fprintf(fid, '%s\n', enc1);
        fprintf(fid, '%s\n', enc2);
        fprintf(fid, '%s\n', ret{1}{1});
        fprintf(fid, '%s\n', ret{1}{2});
        fprintf(fid, '%s\n', ret{2}{1});
        fprintf(fid, '%s\n', ret{2}{2});
        if mod(iTrial, param.scoreFreq) == 0
            fprintf(fid, '%s\n', sc);
        end
    end

    % write last line
    fprintf(fid, sprintf("%d,End,9999,9999,9999,9999,9999,9999,9999,9999,9999", iTrial));

    % close file and figures
    fclose(fid);
    close all;
end

% report
fprintf("All configuration files created.\n");