function sortPointScan

% This function takes a directory containing csv files and an xml file from
% a pointscan and sorts them into subdirectories corresponding to each
% point.

% set the current directory
p =pwd;

% Get all of the csv files in the path
csvFiles = dir('*.csv');

% Import xml data
xml = dir('*.xml');
xmlStruct = xml2struct(xml.name);

% Determine number points and number reps from xml data
numPoints = 1;
for i=1:length(xmlStruct.PVScan.Sequence)    
    if i == 1
        firstPointX = str2num(xmlStruct.PVScan.Sequence{1, i}.PVPointScan.Attributes.ImagingX);
        firstPointY = str2num(xmlStruct.PVScan.Sequence{1, i}.PVPointScan.Attributes.ImagingY);
    elseif str2num(xmlStruct.PVScan.Sequence{1, i}.PVPointScan.Attributes.ImagingX) == firstPointX && str2num(xmlStruct.PVScan.Sequence{1, i}.PVPointScan.Attributes.ImagingY) == firstPointY
        break;
    else
        numPoints = numPoints + 1;
    end   
end

% Ensure the number of points and reps makes sense
if mod(length(csvFiles),numPoints) == 0
    numReps = length(csvFiles)/numPoints;
else
    error('Incorrect number of csvFiles')
end
    
% Make directories for each point
for i=1:numPoints
    mkdir( ['point' num2str(i)] );
end

% Sort csv Files into the directories
for i=1:numPoints    
    for j=0:(numReps-1) 
        
        
        movefile(csvFiles( i + ( j * numPoints ) ).name, ['point' num2str(i)] );
    end
end

% Move the images into a References folder 
mkdir('References');
movefile('*.tif', 'References') ;

% Return to the starting directory
cd(p);



    
    
    
