function LK_GardenGame_PlotTreeXZ_20230814(fcfg)
%
% LK_GardenGame_PlotTreeXZ_20230814 plots the tree locations.
%
% Lukas Kunz, 2023

% create figure
f = figure('units', 'centimeters', 'position', [2, 2, fcfg.param.arena.edgeLength / 2 + 2, fcfg.param.arena.edgeLength / 2 + 2]);
axes('units', 'centimeters', 'position', [1.5, 1.5, fcfg.param.arena.edgeLength / 2, fcfg.param.arena.edgeLength / 2]);
hold on;
plot(fcfg.treeXZ(:, 1), fcfg.treeXZ(:, 2), 'x', 'Color', [0, 0.5, 0], 'MarkerSize', 20, 'LineWidth', 1);
for iX = 1:size(fcfg.param.tree.xRange, 1)
    for iZ = 1:size(fcfg.param.tree.zRange, 1)
        plot([fcfg.param.tree.xRange(iX, 1), fcfg.param.tree.xRange(iX, 2), fcfg.param.tree.xRange(iX, 2), fcfg.param.tree.xRange(iX, 1), fcfg.param.tree.xRange(iX, 1)], ...
            [fcfg.param.tree.zRange(iZ, 1), fcfg.param.tree.zRange(iZ, 1), fcfg.param.tree.zRange(iZ, 2), fcfg.param.tree.zRange(iZ, 2), fcfg.param.tree.zRange(iZ, 1)], ...
            '-', 'Color', [0, 0, 0]);
    end
end
set(gca, 'xlim', fcfg.param.arena.xLim, 'ylim', fcfg.param.arena.zLim, 'box', 'on');
xl = xlabel('x');
yl = ylabel('y');
set([gca, xl, yl], 'fontunits', 'centimeters', 'fontsize', 0.4);
% save figure
print(f, strcat(fcfg.paths.figures, "Subject", sprintf('%d', fcfg.iSub), "_TreeConfig"), '-dpng', '-r150');