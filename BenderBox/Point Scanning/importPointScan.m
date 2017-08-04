function pointscan = importPointScan

% This function is designed to create a pointscan struct from from
% directory that contains cvs files (sorted or unsorted), reference image
% files, and an xml file for the proposes of HOTSPOT Analysis

% It will automatically determine the number of points and repititions,
% point order, and distance between points, and it will calculate a variety
% of parameters for hotspot analysis

% MATLAB FUNCTION REQUIREMENTS:
% xml2struct.m 
% determineHotspotSignficance
% sortPointScan
% unsortPointScan

% Currently these are the components of a hotspot struct (with example
% values):
%               greenPMTGain: 800
%                 redPMTGain: 700
%                 laserPower: 27
%                         fs: 20000
%                   scanTime: 0.1250
%            spikeInitiation: 0.0250
%         hotspotWindowStart: 0.0200
%        hotspotWindowLength: 0.0150
%     hotspotAveragingWindow: 10
%              smoothingSpan: 20
%               smoothingSTD: 3
%                       name: 'PointScan-06112015-1251-002'
%                       date: '6/11/2015 3:38:25 PM'
%                  numPoints: 8
%                 pointOrder: [1 3 5 7 2 4 6 8]
%              pointDistance: [0 0.5200 1.0765 1.5562 2.1041 2.5892 3.1130 3.5964]
%                    numReps: 10
%                     rawRed: [8x2500x11 double]
%                   rawGreen: [8x2500x11 double]
%                  rawGoverR: [8x2500x11 double]
%                smoothedRed: [8x2500x11 double]
%              smoothedGreen: [8x2500x11 double]
%             smoothedGoverR: [8x2500x11 double]
%                     points: {8x10 cell}
%              meanRawGoverR: [2500x1 double]
%                redOverTime: [25000x8 double]
%                     legend: {1x8 cell}
%         normSmoothedGoverR: [8x2500x11 double]
%              normRawGoverR: [8x2500x11 double]
%              maxGoverRTime: 0.0321
%                 windowPeak: [8x1x10 double]
%                hotspotMean: [0.0660 0.0561 0.0519 0.0496 0.0274 0.0695 0.0486 0.0961]
%                 hotspotSTD: [0.0258 0.0228 0.0375 0.0202 0.0325 0.0431 0.0178 0.0517]
%                 hotspotSEM: [0.0082 0.0072 0.0119 0.0064 0.0103 0.0136 0.0056 0.0164]
%               significance: 0.0165
%                      image: [521x521x4 uint8]

% Written by Perry Spratt 2015-07-07

%% Import xml data
xml = dir('*.xml');
xmlStruct = xml2struct(xml.name);

%% Imaging Parameters
pointscan.greenPMTGain = str2num(xmlStruct.PVScan.Sequence{1, 1}.Frame.PVStateShard.Key{1, 23}.Attributes.value);
pointscan.redPMTGain = str2num(xmlStruct.PVScan.Sequence{1, 1}.Frame.PVStateShard.Key{1, 25}.Attributes.value); 
pointscan.laserPower = str2num(xmlStruct.PVScan.Sequence{1, 1}.Frame.PVStateShard.Key{1, 28}.Attributes.value);

%% Recording parameteres
pointscan.fs = 20000; %USER SET (Hz)
pointscan.scanTime = str2num((xmlStruct.PVScan.Sequence{1, 1}.PVPointScan.Attributes.Duration))/1000; % pointscan recording time in seconds
numSamples = pointscan.fs*pointscan.scanTime; %number of samples per scan
pointscan.spikeInitiation = 0.025; %USER SET (s)

%% Hotspot Analysis Parameters
pointscan.hotspotWindowStart = pointscan.spikeInitiation-0.005;%USER SET (s)
pointscan.hotspotWindowLength = 0.015; %USER SET (s)
hotspotWindowStart = pointscan.hotspotWindowStart*pointscan.fs; %hotspot window starts 5ms before the action potential is initiated 
hotspotWindowLength = 0.015*pointscan.fs; %USER SET (ms)
hotspotWindowEnd = hotspotWindowStart + hotspotWindowLength;
pointscan.hotspotAveragingWindow = 10; %USER SET (number of points)

%% Smooothing Parameters 
pointscan.smoothingSpan = 20; %USER SET
pointscan.smoothingSTD = 3; %USER SET
baselineWindowStart = 0.005*pointscan.fs; % %USER SET (s)
baselineWindowEnd = 0.020*pointscan.fs; % %USER SET (s)

%% Extract Pointscan Data 
% Define starting path
path = pwd;

% Define point scan name
[~, deepestFolder] = fileparts(path);
pointscan.name = deepestFolder;

% Define pointscan date and time
pointscan.date = xmlStruct.PVScan.Attributes.date;

% Define names and number or point directories
try 
    pointDirectories  = dir('point*');
    pointscan.numPoints = length(pointDirectories);
catch %if point
    unsortPointScan;
    sortPointScan;
    pointDirectories  = dir('point*');
    pointscan.numPoints = length(pointDirectories);
end
    
% Determine Point Order
for i=1:pointscan.numPoints     
     points(i,1) = str2num(xmlStruct.PVScan.Sequence{1, i}.PVPointScan.Attributes.ImagingX);
     points(i,2) = str2num(xmlStruct.PVScan.Sequence{1, i}.PVPointScan.Attributes.ImagingY);
end

[~, pointOrder] = sort(points(:,2));
pointscan.pointOrder = pointOrder';

% Determine Distance between points 
temp = points; 

for i=1:length(pointOrder)
    points(i,1) = temp(pointscan.pointOrder(i),1);
    points(i,2) = temp(pointscan.pointOrder(i),2);
end

for i=1:length(points(:,1))
    if i == 1
        pointscan.pointDistance(i) = 0;
    else
        pointscan.pointDistance(i) = pointscan.pointDistance(i-1) + sqrt( (points(i,1) - points(i-1,1)).^2 + (points(i,2) - points(i-1,2)).^2);
    end
end

micronPerPixelX = str2num(xmlStruct.PVScan.Sequence{1, 1}.Frame.PVStateShard.Key{1, 21}.Attributes.value);
numPixelsX = str2num(xmlStruct.PVScan.Sequence{1, 1}.Frame.PVStateShard.Key{1, 6}.Attributes.value);

pointscan.pointDistance = pointscan.pointDistance * (micronPerPixelX*numPixelsX);

% Extract data from csv files for each point 
for i=1:length(pointDirectories)
    
%   Moved to the point directory  
    cd(pointDirectories(i).name)
    
%   Get the file names
    reps = dir('*.csv');
    pointscan.numReps = length(reps);
    
%   Read each csv file and convert it to a matrix
    for j=1:length(reps)

        pointscan.points{i,j} = csvread(reps(j).name);

        if i == 1 %The first point is different than the others
            
            if j == 1 %Set time (only once)
                pointscan.time = pointscan.points{i,j}(2:2501,1);
            end
   
            pointscan.rawRed(i,:,j) = pointscan.points{i,j}(2:2501,2);
            pointscan.rawGreen(i,:,j) = pointscan.points{i,j}(2:2501,3);
            pointscan.rawGoverR(i,:,j) = pointscan.points{i,j}(2:2501,3)./pointscan.points{i,j}(2:2501,2);
        
        else %Skip the time when the laser is not on
            
            pointscan.rawRed(i,:,j) = pointscan.points{i,j}(numSamples+1:end,2);
            pointscan.rawGreen(i,:,j) = pointscan.points{i,j}(numSamples+1:end,3);
            pointscan.rawGoverR(i,:,j) = pointscan.points{i,j}(numSamples+1:end,3)./pointscan.points{i,j}(numSamples+1:end,2);
            
        end
              
%       Create a smoothed GoverR (temp vectors used because conv adds tails)
        tempSmoothedRed = conv(pointscan.rawRed(i,:,j),fspecial('gaussian',[pointscan.smoothingSpan 1],pointscan.smoothingSTD));
        tempSmoothedGreen = conv(pointscan.rawGreen(i,:,j),fspecial('gaussian',[pointscan.smoothingSpan 1],pointscan.smoothingSTD));
%         tempSmoothedGoverR = conv(pointscan.rawGoverR(i,:,j),fspecial('gaussian',[pointscan.smoothingSpan 1],pointscan.smoothingSTD));
            
        pointscan.smoothedRed(i,:,j) = tempSmoothedRed(floor(pointscan.smoothingSpan/2):end-ceil(pointscan.smoothingSpan/2));
        pointscan.smoothedGreen(i,:,j) = tempSmoothedGreen(floor(pointscan.smoothingSpan/2):end-ceil(pointscan.smoothingSpan/2));
%         pointscan.smoothedGoverR(i,:,j) = tempSmoothedGoverR(floor(pointscan.smoothingSpan/2):end-ceil(pointscan.smoothingSpan/2));
        pointscan.smoothedGoverR(i,:,j) = pointscan.smoothedGreen(i,:,j)./pointscan.smoothedRed(i,:,j);
        
%       Create Normalized GoverR matricies (subtractive normalization)
        pointscan.normSmoothedGoverR(i,:,j) = pointscan.smoothedGoverR(i,:,j)-mean(pointscan.smoothedGoverR(i,baselineWindowStart:baselineWindowEnd,j));
        pointscan.normRawGoverR(i,:,j) = pointscan.rawGoverR(i,:,j)-mean(pointscan.rawGoverR(i,baselineWindowStart:baselineWindowEnd,j));
             
    end % end of going through reps

%   Create legend from plots  
   pointscan.legend(i) = {['Point ' num2str(i)]};
   
   cd(path);
    
end 

% Create Data for hotspot anaylsis
% Extract data from the window 
windowSmoothed = pointscan.normSmoothedGoverR(:,hotspotWindowStart:hotspotWindowEnd,1:end);
windowRaw = pointscan.normRawGoverR(:,hotspotWindowStart:hotspotWindowEnd,1:end);

padding = pointscan.hotspotAveragingWindow;

windowSmoothedPadded = pointscan.normSmoothedGoverR(:,hotspotWindowStart-padding:hotspotWindowEnd+padding,1:end);
windowRawPadded = pointscan.normRawGoverR(:,hotspotWindowStart-padding:hotspotWindowEnd+padding,1:end);

% Flatted the 3D matrix into a 2D matrix by averaging across the reps for
% each point for determining the max value
windowMean = mean(windowSmoothed,3);

% CURRENTLY THIS METHOD WORKS BY TAKING THE MAX GoverR VALUE AT A *SINGLE*
% TIMEPOINT. IT MIGHT BE BETTER TO ACTUALLY LOOK FOR THE MAX AVERAGED
% ACROSS MULTIPLE POINTS

% Determine the index of the max GoverR value across all points within the hotspot
% anaylsis window
[~, maxIndex] = max(windowMean(:));
% Determine at what time the peak value was achived 
[~, maxTime] = ind2sub(size(windowMean), maxIndex);

pointscan.maxGoverRTime = (maxTime + hotspotWindowStart)/pointscan.fs; % This the time index at which the maximum G over R occurs

%   Extract the data around the max for each point (set to windowSmooth or
%   windowRaw as you wish)
pointscan.windowPeak = mean(windowRawPadded(:,(maxTime-pointscan.hotspotAveragingWindow+padding):(maxTime+pointscan.hotspotAveragingWindow+padding),:),2);

% Go through each point and extract the mean and std values for GoverR a
for i=1:length(pointDirectories)

%   Determine the mean, STD, and SEM of the GoverR values around the peak
%   time for each point 
    pointscan.hotspotMean(i) = mean(pointscan.windowPeak(i,1,:));
    pointscan.hotspotSTD(i) = std(pointscan.windowPeak(i,1,:));
    pointscan.hotspotSEM(i) = std(pointscan.windowPeak(i,1,:)/sqrt(length(pointscan.windowPeak(i,1,:))));
end

% Determine whether the hotspot is significant
pointscan.significance = determineHotspotSignficance(pointscan);

%% Extract the image from the pointscan
cd('References');
tiffImage = dir('PointScan*ImageWindow*');
pointscan.image = imread(tiffImage.name);
cd('..');


%% Save the pointscan
structName = genvarname(pointscan.name);
saveStruct.(structName) = pointscan();

save([pointscan.name '.mat'],'-struct', 'saveStruct'); 

        
        





