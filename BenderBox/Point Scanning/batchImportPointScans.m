function pointscanSegments = batchImportPointScans
% This function is designed to be called from a cell directory containing
% pointscan subdirectories. It will import all of the pointscans in the
% subdirectory

% The function requires user input to determine whether two pointscans are
% from the same axon segment 

% The output of the function is a cell array of each pointscan with the
% different segments organized by column 

% Set Parent direcotry
p =pwd;

% Determine the names of the pointscan directories
pointscanDirectory = dir('PointScan*');

% Set cell name
[~, deepestFolder] = fileparts(p);
cellName = deepestFolder;

% Import all the pointscans
j=1;
for i=1:length(pointscanDirectory)
    try
        cd(pointscanDirectory(i).name);
        pointscans{j} = importPointScan;
        disp([pointscanDirectory(i).name ' imported']);
        j=j+1;
    catch
         disp(['There was an error importing ' pointscanDirectory(i).name]);
         i = i-1;
    end
    
     cd(p);
end

% Go through each pointscan 
segment = 1;
segRep = 1;
for i=1:length(pointscans)
   

    if  ~exist('currentImage') 
%             if there is no image saved set the image and move to the next
%             pointscan
        currentImage = pointscans{i}.image;
        currentTitle = pointscans{i}.name;
        pointscanSegments{segment,segRep} = pointscans{i};

    else          
%             Compare the previous pointscans location to the current
%             pointscans location
        previousImage = currentImage;
        previousTitle = currentTitle;

        currentImage = pointscans{i}.image;
        currentTitle = pointscans{i}.name;

        figure(1);
        subplot(1,2,1);
        imshow(previousImage(:,:,1));
        title(previousTitle);
        subplot(1,2,2);
        imshow(currentImage(:,:,1));
        title(currentTitle);

%             Ask for user input for whether the location of the previous
%             and current point scan are the same
        j=1; 
        while j == 1
            prompt = [pointscanDirectory(i).name ': Same Segment? (y/n):'];
            answer = input(prompt,'s');

            if strcmp(answer,'y')
                segRep = segRep+1;
                pointscanSegments{segment,segRep} = pointscans{i};
                j = j+1;


            elseif strcmp(answer,'n') 
                segment = segment +1;
                segRep = 1;
                pointscanSegments{segment,segRep} = pointscans{i};
                j = j+1;

            else
                disp('Answer must be y or n (case-sensitive)')
            end
        end
    end
    
end

% Save the cell array
save([cellName '.mat'],'pointscanSegments');

    
    
    
    
    
    
    
    
