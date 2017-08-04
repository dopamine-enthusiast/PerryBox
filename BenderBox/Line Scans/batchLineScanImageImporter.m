function batchLineScanImageImporter

cellDirs = uipickfiles; %pick folders to import

for i =1:length(cellDirs)
    if isdir(cellDirs{i}) %Check if directory
        identifyLineScanFolders(cellDirs{i}) %pass directory to linescan parsing function
    end
end
end


% -----Local Function-----
function identifyLineScanFolders(cellDir)
%Identify
lsContents = dir([cellDir filesep 'LineScan*']);

for i=1:length(lsContents)
    if lsContents(i).isdir
        [temp, cellname] = fileparts(cellDir);        
        filename = [cellname ' ' lsContents(i).name];
        try
            rotateAndSaveLSImage([lsContents(i).folder filesep lsContents(i).name],filename)
        catch
            warning([filename ' could not be imported']);
        end        
    end
end
end


% -----Local Function-----
function rotateAndSaveLSImage(path,filename)

savePath = '/Users/perryspratt/Google Drive/Lab/Data/Analysis/LineScan Images';

lsObj = lineScan(path);

%Parse the xml data for location and rotation angle
for i=1:length(lsObj.xmlData.PVScan.Sequence{1, 1}.Frame.PVStateShard.Key)
    if strcmp(lsObj.xmlData.PVScan.Sequence{1, 1}.Frame.PVStateShard.Key{1, i}.Attributes.key,'rotation')
        angle  = str2double(lsObj.xmlData.PVScan.Sequence{1, 1}.Frame.PVStateShard.Key{1, i}.Attributes.value);
    end
    
    if strcmp(lsObj.xmlData.PVScan.Sequence{1, 1}.Frame.PVStateShard.Key{1, i}.Attributes.key,'positionCurrent_XAxis')
        xPos = lsObj.xmlData.PVScan.Sequence{1, 1}.Frame.PVStateShard.Key{1, i}.Attributes.value;
    end
    
    if strcmp(lsObj.xmlData.PVScan.Sequence{1, 1}.Frame.PVStateShard.Key{1, i}.Attributes.key,'positionCurrent_YAxis')
        yPos = lsObj.xmlData.PVScan.Sequence{1, 1}.Frame.PVStateShard.Key{1, i}.Attributes.value;
        
    end
    
    if strcmp(lsObj.xmlData.PVScan.Sequence{1, 1}.Frame.PVStateShard.Key{1, i}.Attributes.key,'positionCurrent_ZAxis')
        zPos = lsObj.xmlData.PVScan.Sequence{1, 1}.Frame.PVStateShard.Key{1, i}.Attributes.value;
    end
end

imFile = dir([path filesep 'References' filesep '*Cycle00001*16bit-Reference.tif']);

im = uint8(imread([imFile(1).folder filesep imFile(1).name]));

rotatedIm = imrotate(im,angle);
imshow(rotatedIm);
imwrite(rotatedIm,[savePath filesep filename ' [' xPos ',' yPos ',' zPos '].png']);
disp([filename '.png saved']);

end
