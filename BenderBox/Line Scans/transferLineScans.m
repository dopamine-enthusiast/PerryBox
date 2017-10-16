function transferLineScans

root = pwd;

originDirs = uipickfiles;
if isempty(originDirs)
    error('You must selected a directory');
end

%Get save location
saveDir = uigetdir('Select Save Location');


disp('Searching for lineScan Folders in...');
%initialize lineScanDir
matDirs = [];
pngDirs = []
for i=1:length(originDirs)
    [a b] = fileparts(originDirs{i});
    disp(b);
    matTemp = subdir(fullfile(originDirs{i},'LineScan*mat'));
    pngTemp = subdir(fullfile(originDirs{i},'*.png'));
    matDirs = cat(1,matDirs,matTemp);     
    pngDirs = cat(1,matDirs,pngTemp);
end
disp('Done Searching');

for i=1:length(matDirs)   
    [path, fileName fileExtension] = fileparts(matDirs(i).name);    
    savePath = [saveDir filesep path(length(root)+2:end)];
    
    if ~exist(savePath,'dir')%make a direcotry for the save path if it doesn't already exist
        mkdir(savePath);
    end  
    
    copyfile(matDirs(i).name,savePath);
end

for i=1:length(pngDirs)   
    [path, fileName fileExtension] = fileparts(pngDirs(i).name);    
    savePath = [saveDir filesep path(length(root)+2:end)];
    
    if ~exist(savePath,'dir')%make a direcotry for the save path if it doesn't already exist
        mkdir(savePath);
    end  
    
    copyfile(pngDirs(i).name,savePath);
end


disp('Transfer Complete');
