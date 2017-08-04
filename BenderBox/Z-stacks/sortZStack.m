function sortZStack



if ~exist('Red','dir')
mkdir('Red');
end

if ~exist('Green','dir')
    mkdir('Green');
end

if ~exist('DIC','dir')
    mkdir('DIC');
end

redFiles = dir('*CurrentSettings_Ch1*');
for i=1:length(redFiles);
    movefile(redFiles(i).name,'Red');
end

greenFiles = dir('*CurrentSettings_Ch2*');
for i=1:length(greenFiles);
    movefile(greenFiles(i).name,'Green');
end

DICFiles = dir('*CurrentSettings_Ch3*');
for i=1:length(DICFiles);
    movefile(DICFiles(i).name,'DIC');
end


%Clean up empty folders
folders = dir(pwd);

for i=1:length(folders)
    if folders(i).isdir == 1 &&... %is a directory
            ~strcmp(folders(i).isdir,'.') &&...%not '.'
            ~strcmp(folders(i).isdir,'..') &&...%'not '..'
            length(dir(folders(i).name)) == 2%'has more that '.' and '..' as contents
        rmdir(folders(i).name);
    end
end