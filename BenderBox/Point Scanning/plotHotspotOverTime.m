function plotHotspotOverTime(pointscanCellArray)
% This function creates a plot of the size of a hotspot over time. It takes
% input of a pointscanCellArray created by batchImportPointScans.m

% The function assumes that points are spaced 0.5um apart

% Written by Perry Spratt 2015-07-07

% Go through each pointscan in the pointscan cell array
for i=1:length(pointscanCellArray)
    
%     Sort into correct order
    tempMean = pointscanCellArray{i}.hotspotMean;
    tempSEM = pointscanCellArray{i}.hotspotSEM;

    for j=1:length(pointscanCellArray{i}.hotspotMean)
         correctHotspotMean(j) = tempMean(pointscanCellArray{i}.pointOrder(j));
         correctSEM(j) = tempSEM(pointscanCellArray{i}.pointOrder(j));
    end

%%    Create time axis
%   Find hotspot peak
    [maxValue, maxIndex] = max(correctHotspotMean);
       
%     parse time from pointscan.date field
    colonIndex = strfind(pointscanCellArray{i}.date,':');
    
%     determine start time
    if i == 1
        startTime = str2num(pointscanCellArray{i}.date([colonIndex(1)+1:colonIndex(2)-1]));
    end
    
%     Determine relative time of each point
    if str2num(pointscanCellArray{i}.date([colonIndex(1)+1:colonIndex(2)-1])) - startTime < 0
        time(i)= [str2num(pointscanCellArray{i}.date([colonIndex(1)+1:colonIndex(2)-1])) - startTime + 60]; 
    else 
        time(i)= [str2num(pointscanCellArray{i}.date([colonIndex(1)+1:colonIndex(2)-1])) - startTime];
    
    end
    
%% Create the peakGoverR axis 

% Divide the pointscan peak by the mean GoverR 1um away (assumes each index
% is 0.5um)
    if maxIndex+2 > length(pointscanCellArray{i}.hotspotMean)
        peakGoverR(i) = pointscanCellArray{i}.hotspotMean(maxIndex)/pointscanCellArray{i}.hotspotMean(maxIndex-2);     
    elseif (maxIndex-2 <= 0)
        peakGoverR(i) = pointscanCellArray{i}.hotspotMean(maxIndex)/pointscanCellArray{i}.hotspotMean(maxIndex+2);
    else   
        peakGoverR(i) = pointscanCellArray{i}.hotspotMean(maxIndex)/mean([pointscanCellArray{i}.hotspotMean(maxIndex-2) pointscanCellArray{i}.hotspotMean(maxIndex+2)]);     
    end
              
end

%% Make the plot
figure;
CM = jet(2);
plot(time,peakGoverR,'LineWidth',4,'color',CM(2,:));
t = title(['Hotspot over time: ', pointscanCellArray{1}.name, ' - ', pointscanCellArray{length(pointscanCellArray)}.name ],'Interpreter','none');
set(t,'FontSize',15,'FontWeight','bold');
ylabel('Hotspot Peak G/R Normalized to G/R 1um away');
xlabel('Time (minutes)');

    