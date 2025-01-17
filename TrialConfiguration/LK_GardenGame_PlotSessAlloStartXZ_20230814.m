function LK_GardenGame_PlotSessAlloStartXZ_20230814(fcfg)
%
% LK_GardenGame_PlotSessAlloStartXZ_20230814 plots the subject's starting
% locations during allocentric retrieval.
%
% Lukas Kunz, 2023

% create figure
f = figure('units', 'centimeters', 'position', [2, 2, fcfg.param.arena.edgeLength / 2 + 2, fcfg.param.arena.edgeLength / 2 + 2]);
axes('units', 'centimeters', 'position', [1.5, 1.5, fcfg.param.arena.edgeLength / 2, fcfg.param.arena.edgeLength / 2]);
plot(cellfun(@(x) x(1), fcfg.sessAlloStartXZ(:)), cellfun(@(x) x(2), fcfg.sessAlloStartXZ(:)), 'kx');
set(gca, 'xlim', fcfg.param.arena.xLim, 'ylim', fcfg.param.arena.zLim, 'box', 'on');
xl = xlabel('x');
yl = ylabel('y');
set([gca, xl, yl], 'fontunits', 'centimeters', 'fontsize', 0.4);
% save figure
print(f, strcat(fcfg.paths.figures, "Subject", sprintf('%d', fcfg.iSub), "_TrialConfig_AlloRetStartLocs"), '-dpng', '-r150');