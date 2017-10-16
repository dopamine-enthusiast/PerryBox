function movie2mat(path)

%Set Basic Variables
sampleRate = 1;

%Start Video Reader
videoReader = VideoReader(path);




%Pull basic vieo information
name = videoReader.Name;
numFrames = videoReader.NumberOfFrames;
readerFrameRate = videoReader.FrameRate;
height = videoReader.Height;
width = videoReader.Width;

stepSize = round(readerFrameRate/sampleRate);

video = struct('cdata',zeros(height,width,3,'uint8'),...
    'colormap',[]);


counter = ceil(numFrames/stepSize);
for i=numFrames:-stepSize:1
    try
    %Get Current Frame
        video(counter).cdata = read(videoReader,i);

        %Display Stage of Processing
        counter = counter - 1;
        disp([name ' Frame ' num2str(ceil(numFrames/stepSize)-counter) ' of ' num2str(ceil(numFrames/stepSize))]);
    catch
        disp(['Problem with Frame ' num2str(ceil(numFrames/stepSize)-counter-1) ' of ' num2str(ceil(numFrames/stepSize))])
    end
    
end


save([name '.mat'], 'video');

end





