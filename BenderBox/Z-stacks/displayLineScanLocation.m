function displayLineScanLocation()

%2017-10-19 Perry Spratt


%load image
disp('Select Max Zstack Projection');
[cell_im,map] = imread(uigetfile('*.tif','Select Max Zstack Projection'));

%display the image
fig = figure;
imshow(cell_im,[]);
title('Double click on soma location');

%create GUI to identify the soma
h = impoint(gca,[]);
wait(h);
soma_pos = getPosition(h);
close(fig);

%check soma coordinates
somaCoords = eval(['[' str2mat(inputdlg('Enter Soma Coordinates','Soma Coordinates',1,{'0,0,0'})) ']']);


%load z-stack xml file
disp('Select zstack xml file');
[fileName,path] = uigetfile('*.xml','Select zstack xml file');

xmlData = (xml2struct([path filesep fileName]));
for i=1:length(xmlData.PVScan.Sequence.Frame{1,1}.PVStateShard.Key)
    if strcmp('micronsPerPixel_XAxis',xmlData.PVScan.Sequence.Frame{1,1}.PVStateShard.Key{i}.Attributes.key)
        scale = str2double(xmlData.PVScan.Sequence.Frame{1,1}.PVStateShard.Key{i}.Attributes.value);%microns/pixel
    end
end

%load linescans from original directories
disp('Load raw linescan directories');
scans = uipickfiles;


if ~exist('Linescan Locations')
    mkdir('Linescan Locations');
end


for i=1:length(scans)
    if isdir(scans{i})
        scan = lineScan(scans{i});
    else
        continue;
    end
    
    
    %Parse xmldata for position and rotation data
    for j=1:length(scan.xmlData.PVScan.Sequence{1, 1}.Frame.PVStateShard.Key)
         if strcmp(scan.xmlData.PVScan.Sequence{1, 1}.Frame.PVStateShard.Key{1, j}.Attributes.key,'rotation')
             angle  = str2double(scan.xmlData.PVScan.Sequence{1, 1}.Frame.PVStateShard.Key{1, j}.Attributes.value);
         elseif strcmp(scan.xmlData.PVScan.Sequence{1, 1}.Frame.PVStateShard.Key{1, j}.Attributes.key,'positionCurrent_XAxis')
             xPos = (str2double(scan.xmlData.PVScan.Sequence{1, 1}.Frame.PVStateShard.Key{1, j}.Attributes.value)-somaCoords(1))/scale;         
         elseif strcmp(scan.xmlData.PVScan.Sequence{1, 1}.Frame.PVStateShard.Key{1, j}.Attributes.key,'positionCurrent_YAxis')
             yPos = (str2double(scan.xmlData.PVScan.Sequence{1, 1}.Frame.PVStateShard.Key{1, j}.Attributes.value)-somaCoords(2))/scale;               
         end
    end
    
    ls_img_filename = dir([scans{i} filesep 'References' filesep '*Reference.tif']);

    ls_im = uint8(imread([scans{i} filesep 'References' filesep ls_img_filename(1).name]));

    rotated_ls_im = imrotate(ls_im(:,:,1:3),angle);
     figure('units','normalized','outerposition',[0.2 0.2 .8 .8])
    subplot(1,2,1)
    imshow(rotated_ls_im);

    subplot(1,2,2)
    imshow(cell_im,[]);
    hold on;
    plot(soma_pos(1)-xPos,soma_pos(2)-yPos,'rs', 'MarkerSize', 30);

    title(scan.name);
    
    saveas(gcf,[pwd filesep 'LineScan Locations' filesep scan.name '_location.png'])
    
    
end






