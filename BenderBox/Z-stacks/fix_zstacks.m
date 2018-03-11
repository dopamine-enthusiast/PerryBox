function fix_zstacks

%Function to fix the issue in prairie that randomly doubles the intensity
%of frames in a zstack

zstack_folders = uipickfiles();

for i=1:length(zstack_folders)
    try
        fix_zstack(zstack_folders{i});
    catch
        warning(['Could not fix ' zstack_folders{i}]);
    end
    
end

end

function fix_zstack(folder_name)

%load tiff files
image_files = dir([folder_name filesep '*.tif']);

%Get median pixel values
for i=1:length(image_files)
    image_data = imread([folder_name filesep image_files(i).name]);
    sorted_pixels = sort(image_data(:));
    mean_image_data(i) = mean(sorted_pixels(1:(length(sorted_pixels)/4)));

end

mkdir([folder_name filesep 'Original Image Files']);
figure;
hold on;
plot(mean_image_data);

threshold = nanmedian(mean_image_data)*1.5;

for i=1:length(image_files)
    image_data = imread([folder_name filesep image_files(i).name]);
    imwrite(image_data,[folder_name filesep 'Original Image Files' filesep image_files(i).name])
    
    sorted_pixels = sort(image_data(:));
    
    if mean(sorted_pixels(1:length(sorted_pixels)/4)) >= threshold
         image_data = image_data./2;
    end
   
    sorted_pixels = sort(image_data(:));
    mean_image_data(i) = mean(sorted_pixels(1:length(sorted_pixels)/4));
    imwrite(image_data,[folder_name filesep image_files(i).name])
end

plot(mean_image_data);
end

