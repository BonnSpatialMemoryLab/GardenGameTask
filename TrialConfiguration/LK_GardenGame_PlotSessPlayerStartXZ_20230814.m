function LK_GardenGame_PlotSessPlayerStartXZ_20230814(fcfg)
%
% LK_GardenGame_PlotSessPlayerStartXZ_20230814 plots the subject's starting
% locations.
%
% Lukas Kunz, 2023

f = figure('units', 'centimeters', 'position', [2, 2, fcfg.param.arena.edgeLength / 2 + 2, fcfg.param.arena.edgeLength / 2 + 2]);
axes('units', 'centimeters', 'position', [1.5, 1.5, fcfg.param.arena.edgeLength / 2, fcfg.param.arena.edgeLength / 2]);
hold on;
plot(fcfg.sessPlayerStartXZ(:, 1), fcfg.sessPlayerStartXZ(:, 2), 'kx'); % player starting locations
plot([fcfg.param.player.xRange(1), fcfg.param.player.xRange(2), fcfg.param.player.xRange(2), fcfg.param.player.xRange(1), fcfg.param.player.xRange(1)], ...
    [fcfg.param.player.zRange(1), fcfg.param.player.zRange(1), fcfg.param.player.zRange(2), fcfg.param.player.zRange(2), fcfg.param.player.zRange(1)], ...
    '--', 'Color', [0.5, 0.5, 0.5]); % possible range for starting locations
plot(fcfg.stableObjXZ(:, 1), fcfg.stableObjXZ(:, 2), 'ro'); % stable object locations without jitter
plot(fcfg.treeXZ(:, 1), fcfg.treeXZ(:, 2), 'x', 'Color', [0, 0.5, 0], 'MarkerSize', 10, 'LineWidth', 4); % tree locations
hold off;
set(gca, 'xlim', fcfg.param.arena.xLim, 'ylim', fcfg.param.arena.zLim, 'box', 'on');
xl = xlabel('x');
yl = ylabel('y');
set([gca, xl, yl], 'fontunits', 'centimeters', 'fontsize', 0.4);
% save figure
print(f, strcat(fcfg.paths.figures, "Subject", sprintf('%d', fcfg.iSub), "_TrialConfig_PlayerStartXZ"), '-dpng', '-r150');