function LK_GardenGame_PlotSessObjXZ_20230814(fcfg)
%
% LK_GardenGame_PlotSessObjXZ_20230814 plots the object locations.
%
% Lukas Kunz, 2023

% create figure
f = figure('units', 'centimeters', 'position', [2, 2, fcfg.param.arena.edgeLength / 2 + 2, fcfg.param.arena.edgeLength / 2 + 2]);
axes('units', 'centimeters', 'position', [1.5, 1.5, fcfg.param.arena.edgeLength / 2, fcfg.param.arena.edgeLength / 2]);
hold on;
for iTrial = 1:size(fcfg.sessObjXZ, 1)
    plot(fcfg.sessObjXZ{iTrial, 1}(1), fcfg.sessObjXZ{iTrial, 1}(2), 'rx'); % first object in that trial
    plot(fcfg.sessObjXZ{iTrial, 2}(1), fcfg.sessObjXZ{iTrial, 2}(2), 'bx'); % second object in that trial
    plot([fcfg.sessObjXZ{iTrial, 1}(1), fcfg.sessObjXZ{iTrial, 2}(1)], [fcfg.sessObjXZ{iTrial, 1}(2), fcfg.sessObjXZ{iTrial, 2}(2)], ...
        '--', 'Color', [0.5, 0.5, 0.5]); % path between the two objects
end
set(gca, 'xlim', fcfg.param.arena.xLim, 'ylim', fcfg.param.arena.zLim, 'box', 'on');
xl = xlabel('x');
yl = ylabel('y');
set([gca, xl, yl], 'fontunits', 'centimeters', 'fontsize', 0.4);
% save figure
print(f, strcat(fcfg.paths.figures, "Subject", sprintf('%d', fcfg.iSub), "_TrialConfig_ObjLocPathsPerTrial"), '-dpng', '-r150');