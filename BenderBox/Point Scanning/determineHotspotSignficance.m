function significance = determineHotspotSignficance(pointscan)
% This function preforms a t-test of the peak g/r values compared to the
% g/r values 1um away and returns the p value. Assumes that points are
% spaced 0.5um apart

% Sort to correct order
tempMean = pointscan.hotspotMean;
tempSEM = pointscan.hotspotSEM;
tempWindow = pointscan.windowPeak;

window = zeros(size(tempWindow));

for i=1:length(pointscan.hotspotMean)
    pointscan.hotspotMean(i) = tempMean(pointscan.pointOrder(i));
    pointscan.hotspotSEM(i) = tempSEM(pointscan.pointOrder(i));
    window(i,:,:) = tempWindow(pointscan.pointOrder(i),:,:);  
end

% Find the peak of the hotspot
[maxValue, maxIndex] = max(pointscan.hotspotMean(:));
[a, b] = ind2sub(size(pointscan.hotspotMean), maxIndex);

% Determine whether the peak is significant
if maxIndex+2 > length(pointscan.hotspotMean)
  
    [h,p] = ttest2(window(maxIndex-2,1,:),window(maxIndex,1,:));
    significance = p;  
    
elseif (maxIndex-2 <= 0)

    [h,p] = ttest2(window(maxIndex,1,:),window(maxIndex+2,1,:));
    significance = p;
    
else
   
    [h1,p1] = ttest2(window(maxIndex-2,1,:),window(maxIndex,1,:));
    [h2,p2] = ttest2(window(maxIndex,1,:),window(maxIndex+2,1,:));
    significance = max([p1 p2]);
    
end