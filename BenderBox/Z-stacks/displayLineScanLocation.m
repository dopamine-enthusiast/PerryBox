function displayLineScanLocation()

%2017-10-19 Perry Spratt


%load image
disp('Select Max Zstack Projection');
[cell_im,~] = imread(uigetfile('*.tif','Select Max Zstack Projection'));

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
scanDirs = uipickfiles;


if ~exist('Linescan Locations')
    mkdir('Linescan Locations');
end

scans = [];
valid_scanDirs = {};
for i=1:length(scanDirs)
    if isdir(scanDirs{i})
        try
            scans = [scans, lineScan(scanDirs{i})];
            valid_scanDirs = [valid_scanDirs, scanDirs{i}];
        catch
            disp([scanDirs{i} ' must be a directory']);
        end
    else
        disp([scans{i} ' must be a directory']);
        continue;
    end
end

[~, cellname] = fileparts(pwd);


for i=1:length(scans)
    scan = scans(i); %ugly I know, but I 
    %Parse xmldata for position and rotation data
    for j=1:length(scans(i).xmlData.PVScan.Sequence{1, 1}.Frame.PVStateShard.Key)
         if strcmp(scans(i).xmlData.PVScan.Sequence{1, 1}.Frame.PVStateShard.Key{1, j}.Attributes.key,'rotation')
             angle  = str2double(scans(i).xmlData.PVScan.Sequence{1, 1}.Frame.PVStateShard.Key{1, j}.Attributes.value);
         elseif strcmp(scans(i).xmlData.PVScan.Sequence{1, 1}.Frame.PVStateShard.Key{1, j}.Attributes.key,'positionCurrent_XAxis')
             xPos = (str2double(scans(i).xmlData.PVScan.Sequence{1, 1}.Frame.PVStateShard.Key{1, j}.Attributes.value)-somaCoords(1))/scale;         
         elseif strcmp(scans(i).xmlData.PVScan.Sequence{1, 1}.Frame.PVStateShard.Key{1, j}.Attributes.key,'positionCurrent_YAxis')
             yPos = (str2double(scans(i).xmlData.PVScan.Sequence{1, 1}.Frame.PVStateShard.Key{1, j}.Attributes.value)-somaCoords(2))/scale;               
         end
    end
    
    if strcmp(scans(i).imagingParams.rig,'bluefish')
        ls_img_filename = dir([valid_scanDirs{i} filesep 'References' filesep '*8bit-Reference.tif']);
    else
        ls_img_filename = dir([valid_scanDirs{i} filesep 'References' filesep '*Reference.tif']);
    end

    ls_im = uint8(imread([valid_scanDirs{i} filesep 'References' filesep ls_img_filename(1).name]));
    
    try
        rotated_ls_im = imrotate(ls_im(:,:,1:3),angle);
    catch
        rotated_ls_im = imrotate(ls_im(:,:,1),angle);
    end
     figure('units','normalized','outerposition',[0.2 0.2 .8 .8])
    subplot(1,2,1)
    imshow(rotated_ls_im);
    title(scan.name);
    
    subplot(1,2,2)
    imshow(cell_im,[]);
    hold on;
    
    if strcmp(scans(i).imagingParams.rig,'bluefish')
        plot(soma_pos(1)+xPos,soma_pos(2)+yPos,'rs', 'MarkerSize', 30);
    else
        plot(soma_pos(1)-xPos,soma_pos(2)-yPos,'rs', 'MarkerSize', 30);
    end
    title(cellname);
    
    saveas(gcf,[pwd filesep 'LineScan Locations' filesep scan.name '_location.png'])
    close(gcf);
end


scans = loadLineScans;


figure('units','normalized','outerposition',[0 0 1 1]);
cm = jet(length(scans));
subplot(1,2,1)
imshow(cell_im,[]);
hold on;
for i=1:length(scans)
    for j=1:length(scans(i).xmlData.PVScan.Sequence{1, 1}.Frame.PVStateShard.Key)
         if strcmp(scans(i).xmlData.PVScan.Sequence{1, 1}.Frame.PVStateShard.Key{1, j}.Attributes.key,'rotation')
             angle  = str2double(scans(i).xmlData.PVScan.Sequence{1, 1}.Frame.PVStateShard.Key{1, j}.Attributes.value);
         elseif strcmp(scans(i).xmlData.PVScan.Sequence{1, 1}.Frame.PVStateShard.Key{1, j}.Attributes.key,'positionCurrent_XAxis')
             xPos = (str2double(scans(i).xmlData.PVScan.Sequence{1, 1}.Frame.PVStateShard.Key{1, j}.Attributes.value)-somaCoords(1))/scale;         
         elseif strcmp(scans(i).xmlData.PVScan.Sequence{1, 1}.Frame.PVStateShard.Key{1, j}.Attributes.key,'positionCurrent_YAxis')
             yPos = (str2double(scans(i).xmlData.PVScan.Sequence{1, 1}.Frame.PVStateShard.Key{1, j}.Attributes.value)-somaCoords(2))/scale;               
         end
    end
    
    
    if strcmp(scans(i).imagingParams.rig,'bluefish')
        plot(soma_pos(1)+xPos,soma_pos(2)+yPos,'s','color',cm(i,:), 'MarkerSize', 30);
    else
       plot(soma_pos(1)-xPos,soma_pos(2)-yPos,'s','color',cm(i,:), 'MarkerSize', 30);
    end
    
    
end

subplot(1,2,2)
hold on;
for i=1:length(scans)
    plot(scans(i).time,scans(i).normGoR,'color',cm(i,:));  
    legendnames{i} = scans(i).name;
end
xlabel('Time (s)');
ylabel('dG/R');

set(gca, 'Box', 'off', 'TickDir', 'out', 'TickLength', [.02 .02], ...
    'XMinorTick', 'on', 'YMinorTick', 'on', 'YGrid', 'on', 'GridLineStyle', '-',...
    'XColor', 'k', 'YColor', 'k',  ...
    'LineWidth', 1,'FontName','arial','FontSize',12);
title(cellname);
legend(legendnames,'FontSize',10,'location','best');
saveas(gcf,[pwd filesep cellname ' summary.png']);
saveas(gcf,[pwd filesep cellname ' summary.fig']);











