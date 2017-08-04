function linescanImageViewer

cellDirs = uipickfiles;

for i =1:length(cellDirs)
    if isdir(cellDirs{i}) %Check if directory
        parseLineScans(cellDirs{i}) %pass to linescan parser
    end
end
       
% -----Local Function-----
function parseLineScans(cellDir)

lsContents = dir('LineScan*');

for i=1:length(lsContents)
    isdir(lsContents(i).name
    
    
end






lsObj = lineScan(pwd);


for i=1:length(lsObj.xmlData.PVScan.Sequence{1, 1}.Frame.PVStateShard.Key)
     if strcmp(lsObj.xmlData.PVScan.Sequence{1, 1}.Frame.PVStateShard.Key{1, i}.Attributes.key,'rotation')
         angle  = str2double(lsObj.xmlData.PVScan.Sequence{1, 1}.Frame.PVStateShard.Key{1, i}.Attributes.value);
     elseif strcmp(lsObj.xmlData.PVScan.Sequence{1, 1}.Frame.PVStateShard.Key{1, i}.Attributes.key,' positionCurrent_XAxis')
         xPos = lsObj.xmlData.PVScan.Sequence{1, 1}.Frame.PVStateShard.Key{1, i}.Attributes.value;         
     elseif strcmp(lsObj.xmlData.PVScan.Sequence{1, 1}.Frame.PVStateShard.Key{1, i}.Attributes.key,' positionCurrent_YAxis')
         yPos = lsObj.xmlData.PVScan.Sequence{1, 1}.Frame.PVStateShard.Key{1, i}.Attributes.value;      
     elseif strcmp(lsObj.xmlData.PVScan.Sequence{1, 1}.Frame.PVStateShard.Key{1, i}.Attributes.key,' positionCurrent_ZAxis')
         zPos = lsObj.xmlData.PVScan.Sequence{1, 1}.Frame.PVStateShard.Key{1, i}.Attributes.value;          
     end
end

imFile = dir([pwd filesep 'References' filesep '*Cycle00001*16bit-Reference.tif']);

im = uint8(imread([imFile(1).folder filesep imFile(1).name]));

rotatedIm = imrotate(im,angle);
imshow(rotatedIm);
imwrite(rotatedIm,'test.png');