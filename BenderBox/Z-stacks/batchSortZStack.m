function batchSortZStack

root = pwd;

selectedDirs = uipickfiles();
zstackDirs = []
for i=1:length(selectedDirs)
    cd(selectedDirs{i})
    temp = subdir('ZSeries-*');
    zstackDirs = [zstackDirs temp'];
end

for i=1:length(zstackDirs)
    
   if zstackDirs(i).isdir
       cd(zstackDirs(i).name);
       disp(zstackDirs(i).name);
       sortZStack;
   end
end

cd(root);