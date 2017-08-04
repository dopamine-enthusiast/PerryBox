function exportLineScans
%% Defined behavior
% Select a folder or set of folders containing raw linescan data generated
% by prairie.
% Create a copy of the driectory tree of all folders that contain a
% subdirectory that has a linescan folder, with the linescan folders converted to linescan.mat files 

root = pwd;

loadDirs = uipickfiles;

%Get save location
saveDir = uigetdir('Select Save Location');

disp('Searching for lineScan Folders in...');
%initialize lineScanDir
lineScanDir = [];
for i=1:length(loadDirs)
    [a b] = fileparts(loadDirs{i});
    disp(b);
    temp = subdir(fullfile(loadDirs{i},'LineScan-*'));
    lineScanDir = cat(1,lineScanDir,temp);        
end
disp('Done Searching');

for i=1:length(lineScanDir)
    if lineScanDir(i).isdir == 1 %Check if directory
        try
            obj = lineScan(lineScanDir(i).name);
            
            [path, deepestFolder] = fileparts(lineScanDir(i).name);
            savePath = [saveDir filesep path(length(root)+2:end)];
            if ~exist(savePath,'dir')%make a direcotry for the save path if it doesn't already exist
                mkdir(savePath);
            end
            saveLS(obj,savePath);
            
            disp([deepestFolder ' imported']);
        catch
            [~, deepestFolder] = fileparts(lineScanDir(i).name);
            disp([deepestFolder ' could not be imported']);
        end
        
    end
end
disp('Import Complete');
