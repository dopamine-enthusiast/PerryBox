function unsortPointScan
% This function will move all files from subdirectories in a pointscan
% folder to the parent directory

% Set current path
p = pwd;

% Get files in the directory

files = dir();

% move all files from the point and reference directories into the
% pointscan directory
for i=1:length(files) 
    if files(i).isdir == 1 && ~strcmp(files(i).name,'.') && ~strcmp(files(i).name,'..')
        try
            movefile(fullfile(files(i).name,'*'));
            rmdir(files(i).name);
        catch % incase the directory is empty 
            rmdir(files(i).name); 
        end
    end
end

% Return to the original directory
cd(p);


    