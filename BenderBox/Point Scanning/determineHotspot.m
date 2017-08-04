function determineHotspot(pointscan)
% This function plots a bar graph comparing the peak g/r value to points
% 1um away. This will also calculate signifcance values for the hotspot.
% Assumes that points are spaced 0.5um apart

% REQUIREMENTS:
% sigstar.m


%% Align the points to the correct order

tempMean = pointscan.hotspotMean;
tempSEM = pointscan.hotspotSEM;
tempWindow = pointscan.windowPeak;

window = zeros(size(tempWindow));

for i=1:length(pointscan.hotspotMean)
    pointscan.hotspotMean(i) = tempMean(pointscan.pointOrder(i));
    pointscan.hotspotSEM(i) = tempSEM(pointscan.pointOrder(i));
    window(i,:,:) = tempWindow(pointscan.pointOrder(i),:,:);   
end

[maxValue, maxIndex] = max(pointscan.hotspotMean(:));
[a, b] = ind2sub(size(pointscan.hotspotMean), maxIndex);

figure;
hold on;
CM = jet(2);

if maxIndex+2 > length(pointscan.hotspotMean)
%     plot so the it only includes point 
    meanValues = [pointscan.hotspotMean(maxIndex-2) pointscan.hotspotMean(maxIndex)];
    errors = [pointscan.hotspotSEM(maxIndex-2) pointscan.hotspotSEM(maxIndex)];

    b = bar([-1 0], meanValues,0.5);
    set(b,'facecolor',CM(1,:));
    
    errorbar([-1 0],meanValues,errors,'.k','MarkerSize',5);
    
    [h,p] = ttest2(window(maxIndex-2,1,:),window(maxIndex,1,:));
    sigstar([-1 0],[p]);
    
     if h == 1
        
       t = title({[pointscan.name ' - Hotspot']},'Interpreter','none');
     else
       t = title({[pointscan.name ' - No Hotspot']},'Interpreter','none');
     end
     
    
elseif (maxIndex-2 <= 0)
%     plot so it only contains the upper point 
    meanValues = [pointscan.hotspotMean(maxIndex) pointscan.hotspotMean(maxIndex+2)];
    errors = [pointscan.hotspotSEM(maxIndex) pointscan.hotspotSEM(maxIndex+2)];

    b = bar([0 1], meanValues,0.5);
     set(b,'facecolor',CM(1,:));
    
    errorbar([0 1],meanValues,errors,'.k','MarkerSize',5);
    
    [h,p] = ttest2(window(maxIndex,1,:),window(maxIndex+2,1,:));
    sigstar([0 1],[p]);
    
    if h == 1
        
        t = title({[pointscan.name ' - Hotspot']},'Interpreter','none');
    else
         t = title({[pointscan.name ' - No Hotspot']},'Interpreter','none');
    end
    
else
    meanValues = [pointscan.hotspotMean(maxIndex-2) pointscan.hotspotMean(maxIndex) pointscan.hotspotMean(maxIndex+2)];
    errors = [pointscan.hotspotSEM(maxIndex-2) pointscan.hotspotSEM(maxIndex) pointscan.hotspotSEM(maxIndex+2)];
    
    b = bar([-1 0 1], meanValues,0.5);
    set(b,'facecolor',CM(1,:));
    
    errorbar([-1 0 1],meanValues,errors,'.k','MarkerSize',5);
    
    [h1,p1] = ttest2(window(maxIndex-2,1,:),window(maxIndex,1,:));
    [h2,p2] = ttest2(window(maxIndex,1,:),window(maxIndex+2,1,:));
    [h3,p3] = ttest2(window(maxIndex-2,1,:),window(maxIndex+2,1,:)); 
    sigstar({[-1 0],[0 1],[-1 1]},[p1 p2 p3]);
    
     if h1 == 1 && h2 == 1
        
       t = title({[pointscan.name ' - Hotspot']},'Interpreter','none');
     else
        t = title({[pointscan.name ' - No Hotspot']},'Interpreter','none');
    end
     

end


set(t,'FontSize',15,'FontWeight','bold');
ylabel('Peak G/R');
xlabel('Distance from hotspot (um)');

        
% Plot the bar plots 
% Plot the error bars
% Determine significance

    