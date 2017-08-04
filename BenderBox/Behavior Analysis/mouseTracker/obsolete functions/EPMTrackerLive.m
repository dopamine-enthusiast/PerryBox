function EPMTrackerLive



vidDevice = imaq.VideoDevice;
vidDevice.ReturnedColorSpace = 'rgb';
vidInfo = imaqhwinfo(vidDevice);

hVideoIn = vision.VideoPlayer('Name', 'Final Video', ... % Output video player
    'Position', [100 100 vidInfo.MaxWidth+20 vidInfo.MaxHeight+30]);

videoFileWriter = vision.VideoFileWriter('test.avi','FrameRate',1);

hblob = vision.BlobAnalysis('AreaOutputPort', false, ... % Set blob analysis handling
    'CentroidOutputPort', true, ...
    'BoundingBoxOutputPort', true', ...
    'MinimumBlobArea', 100, ...
    'MaximumBlobArea', 3000, ...
    'MaximumCount', 10);
hshapeinsRedBox = vision.ShapeInserter('BorderColor', 'Custom', ... % Set Red box handling
    'CustomBorderColor', [1 0 0], ...
    'Fill', true, ...
    'FillColor', 'Custom', ...
    'CustomFillColor', [1 0 0], ...
    'Opacity', 0.4);
htextins = vision.TextInserter('Text', 'Number of Tracjed Object: %2d', ... % Set text for number of blobs
    'Location', [7 2], ...
    'Color', [1 0 0], ... // red color
    'FontSize', 12);
htextinsCent = vision.TextInserter('Text', '+ X:%4d, Y:%4d', ... % set text for centroid
    'LocationSource', 'Input port', ...
    'Color', [1 1 0], ... // yellow color
    'FontSize', 14);



background = 1-rgb2gray(step(vidDevice));
background = 1-rgb2gray(step(vidDevice));
background = 1-rgb2gray(step(vidDevice));

nFrame = 0;
while(nFrame < 300)
    tic;
     rgbFrame = step(vidDevice);
    diffFrame = (1-rgb2gray(rgbFrame))- background;
    diffFrame = medfilt2(diffFrame, [3 3]);
    binFrame = im2bw(diffFrame, 0.40);
    
    [centroid, bbox] = step(hblob, binFrame); % Get the centroids and bounding boxes of the blobs
    centroid = uint16(centroid); % Convert the centroids into Integer for further steps
    rgbFrame(1:20,1:165,:) = 0; % put a black region on the output stream
    vidIn = step(hshapeinsRedBox, rgbFrame, bbox); % Instert the red box
    for object = 1:1:length(bbox(:,1)) % Write the corresponding centroids
        centX = centroid(object,1); centY = centroid(object,2);
        vidIn = step(htextinsCent, vidIn, [centX centY], [centX-6 centY-9]);
    end
    vidIn = step(htextins, vidIn, uint8(length(bbox(:,1)))); % Count the number of blobs
   step(videoFileWriter, rgbFrame); % Output video stream
   step(hVideoIn, rgbFrame); % Output video stream
    nFrame = nFrame + 1;
    toc;
end