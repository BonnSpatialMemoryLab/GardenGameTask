function LK_GardenGame_PlotSessEgoStartXZ_20230814(fcfg)
%
% LK_GardenGame_PlotSessEgoStartXZ_20230814 plots the subject's starting
% locations during egocentric retrieval.
%
% Lukas Kunz, 2023

f = figure('units', 'centimeters', 'position', [2, 2, fcfg.param.arena.edgeLength / 2 + 2, fcfg.param.arena.edgeLength / 2 + 2]);
axes('units', 'centimeters', 'position', [1.5, 1.5, fcfg.param.arena.edgeLength / 2, fcfg.param.arena.edgeLength / 2]);
hold on;
plot(cellfun(@(x) x(1), fcfg.sessEgoStartXZ(:)), cellfun(@(x) x(2), fcfg.sessEgoStartXZ(:)), 'kx');
plot(cosd(0:0.1:360) * fcfg.param.egoRet.circleFarRad, sind(0:0.1:360) * fcfg.param.egoRet.circleFarRad, '-', 'color', [0.5, 0.5, 0.5]);
set(gca, 'xlim', fcfg.param.arena.xLim, 'ylim', fcfg.param.arena.zLim, 'box', 'on');
xl = xlabel('x');
yl = ylabel('y');
set([gca, xl, yl], 'fontunits', 'centimeters', 'fontsize', 0.4);
% save figure
print(f, strcat(fcfg.paths.figures, "Subject", sprintf('%d', fcfg.iSub), "_TrialConfig_EgoRetStartLocs"), '-dpng', '-r150');