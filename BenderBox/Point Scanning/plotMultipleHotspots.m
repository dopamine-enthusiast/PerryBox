function plotMultipleHotspots(pointscanCellArray,aligned,shader)
% This function is designed to plot peak G/R values over distance of
% multiple pointscans in pointscanCellArray. 

% Optional arguments:
% aligned - 0 is no alignment, 1 set the peak of all the pointscans to be aligned. Default is 0
% 
% shader - 0 no error shading, 1 error shading, default is 1

% Written by Perry Spratt 2015-07-07

figure;
hold on;
CM = jet(length(pointscanCellArray)); %set color map

% go through each pointscan in the cell array
for i=1:length(pointscanCellArray)

%    arrange into the correct order 
    tempMean = pointscanCellArray{i}.hotspotMean;
    tempSEM = pointscanCellArray{i}.hotspotSEM;

    for j=1:length(pointscanCellArray{i}.hotspotMean)
         correctHotspotMean(j) = tempMean(pointscanCellArray{i}.pointOrder(j));
         correctSEM(j) = tempSEM(pointscanCellArray{i}.pointOrder(j));
    end

%     Set x axis depending on whether aslignment is set on or off
    if exist('aligned') && aligned == 1 
        [~, maxIndex] = max( correctHotspotMean);
        pointDistance = pointscanCellArray{i}.pointDistance - pointscanCellArray{i}.pointDistance(maxIndex);
        titleCard = 'Aligned Hotspot Comparison: ';    
    else
        pointDistance = pointscanCellArray{i}.pointDistance;
        titleCard = 'Hotspot Comparison: '; 
    end

%     Plot the pointscan over distance depending on whether the shader was
%     set or not
    if exist('shader') && shader == 0 
        handle = plot(pointDistance,correctHotspotMean,'color',CM(i,:));
    else
        handle = shadedErrorBar(pointDistance,correctHotspotMean, correctSEM,{'color',CM(i,:)});
    end
    
%     Create the legend
    colonIndex = strfind(pointscanCellArray{i}.date,':');
    
    if i == 1
        startTime = str2num(pointscanCellArray{i}.date([colonIndex(1)+1:colonIndex(2)-1]));
    end
    
    if str2num(pointscanCellArray{i}.date([colonIndex(1)+1:colonIndex(2)-1])) - startTime < 0
        legendNames{i} = [num2str(str2num(pointscanCellArray{i}.date([colonIndex(1)+1:colonIndex(2)-1])) - startTime + 60) ' min'];
    else    
        legendNames{i} = [num2str(str2num(pointscanCellArray{i}.date([colonIndex(1)+1:colonIndex(2)-1])) - startTime) ' min']
    end

%     adjust the legend depending on whether the shader was set or not
    if exist('shader') && shader == 0 
%         Do nothing
    else
        legendColors(i) = handle.mainLine;
    end
    
end

% Add titles and axis
t = title([titleCard  pointscanCellArray{1}.name ' - ' pointscanCellArray{length(pointscanCellArray)}.name ],'Interpreter','none');
set(t,'FontSize',15,'FontWeight','bold');
ylabel('Peak G/R Normalized to Baseline');
xlabel('Distance along the axon (um)');

%     adjust the legend depending on whether the shader was set or not
if exist('shader') && shader == 0 
    legend(legendNames,'Location','northwest')
else
    legend(legendColors,legendNames,'Location','northwest');
end
legend('boxoff')

