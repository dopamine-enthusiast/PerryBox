function plotHotspot(pointscan)
% This function plots the peak g/r value for each point in pointscan
% (created by importPointScan)

% REQUIREMENTS
% shadedErrorBar.m


% Align the points to the correct order
tempMean = pointscan.hotspotMean;
tempSEM = pointscan.hotspotSEM;

for i=1:length(pointscan.hotspotMean)
    pointscan.hotspotMean(i) = tempMean(pointscan.pointOrder(i));
    pointscan.hotspotSEM(i) = tempSEM(pointscan.pointOrder(i));
end

% Plot the peak g/r value for each poin
CM = jet(2);
shadedErrorBar(pointscan.pointDistance,pointscan.hotspotMean,pointscan.hotspotSEM,{'color',CM(2,:)})

% Set title and axis
t = title({['Peak G/R per Point for ' pointscan.name]},'Interpreter','none');
set(t,'FontSize',15,'FontWeight','bold');
ylabel('Peak G/R Normalized to Baseline');
xlabel('Distance along the axon (um)');
ylim([0 .18]);


end


