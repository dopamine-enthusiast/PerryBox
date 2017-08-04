function video = videoPreview(path)

%Set Basic Variables
sampleRate = 1;

%Start Video Reader
videoReader = VideoReader(path);




%Pull basic vieo information
name = videoReader.Name;
numFrames = 1800;%videoReader.NumberOfFrames;
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
    catch
        
    end
    
end




end
