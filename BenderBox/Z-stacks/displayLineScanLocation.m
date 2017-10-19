function displayLineScanLocation()

%2017-10-19 Perry Spratt


%load image
[cell_im,map] = imread(uigetfile('*.tif'));

%display the image
fig = figure;
imshow(cell_im,[]);

%create GUI to identify the soma
h = impoint(gca,[]);
wait(h);
soma_pos = getPosition(h);
close(fig);

%check soma coordinates
somaCoords = eval(['[' str2mat(inputdlg('Enter Soma Coordinates','Soma Coordinates',1,{'0,0,0'})) ']']);


%load z-stack xml file
[fileName,path] = uigetfile('*.xml');

xmlData = (xml2struct([path filesep fileName]));
for i=1:length(xmlData.PVScan.Sequence.Frame{1,1}.PVStateShard.Key)
    if strcmp('micronsPerPixel_XAxis',xmlData.PVScan.Sequence.Frame{1,1}.PVStateShard.Key{i}.Attributes.key)
        scale = str2double(xmlData.PVScan.Sequence.Frame{1,1}.PVStateShard.Key{i}.Attributes.value);%microns/pixel
    end
end

%load linescans
lsDirs = uipickfiles;

for i =1:length(lsDirs)
    if isdir(lsDirs{i}) %Check if directory
       parseLineScans(lsDirs{i},cell_im,scale,soma_pos,somaCoords) %pass to linescan parser
    end
end

end


function parseLineScans(lsDir,cell_im,scale,soma_pos,somaCoords)
lsObj = lineScan(lsDir);

for i=1:length(lsObj.xmlData.PVScan.Sequence{1, 1}.Frame.PVStateShard.Key)
     if strcmp(lsObj.xmlData.PVScan.Sequence{1, 1}.Frame.PVStateShard.Key{1, i}.Attributes.key,'rotation')
         angle  = str2double(lsObj.xmlData.PVScan.Sequence{1, 1}.Frame.PVStateShard.Key{1, i}.Attributes.value);
     elseif strcmp(lsObj.xmlData.PVScan.Sequence{1, 1}.Frame.PVStateShard.Key{1, i}.Attributes.key,'positionCurrent_XAxis')
         xPos = (str2double(lsObj.xmlData.PVScan.Sequence{1, 1}.Frame.PVStateShard.Key{1, i}.Attributes.value)-somaCoords(1))/scale;         
     elseif strcmp(lsObj.xmlData.PVScan.Sequence{1, 1}.Frame.PVStateShard.Key{1, i}.Attributes.key,'positionCurrent_YAxis')
         yPos = (str2double(lsObj.xmlData.PVScan.Sequence{1, 1}.Frame.PVStateShard.Key{1, i}.Attributes.value)-somaCoords(2))/scale;               
     end
end

ls_im_fileName = dir([lsDir filesep 'References' filesep '*Reference.tif']);

ls_im = uint8(imread([lsDir filesep 'References' filesep ls_im_fileName(1).name]));

rotated_ls_im = imrotate(ls_im(:,:,1:3),angle);
 figure('units','normalized','outerposition',[0.2 0.2 .8 .8])
subplot(1,2,1)
imshow(rotated_ls_im);

subplot(1,2,2)
imshow(cell_im,[]);
hold on;
plot(soma_pos(1)-xPos,soma_pos(2)-yPos,'rs', 'MarkerSize', 30);

title(lsObj.name);
end








