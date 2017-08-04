function trackMouse(video)

%Set Basic Variables
sampleRate = 10;
bodyThresh = 0.3;
tailThresh = 0.3;
tailFilter = 9;

numFrames = length(video);
background = rgb2gray(video(1).cdata);
time = zeros(numFrames,1);
posCenter = zeros(numFrames,2);
posTail = zeros(numFrames,2);
posHead = zeros(numFrames,2);

for i=1:length(video)
    try
        %Get Current Frame
        grayframe = rgb2gray(video(i).cdata);
        
        %Remove Background
        invFrame = 255-grayframe;
        invBackground = 255 - background;
        diffFrame = invFrame-invBackground;
        
        %Identify entire mouse outline
        binBody = im2bw(diffFrame, tailThresh);
        body =  bwareaopen(binBody, 20, 8);
        body = imfill(body,'holes');
        
        %Identify mouse core
        diffFrameFilt = medfilt2(diffFrame, [tailFilter tailFilter]);%Filter out the tail
        binCenter= im2bw(diffFrameFilt, bodyThresh);
        center = bwareaopen(binCenter, 20, 8);
        center = imfill(center,'holes');
        
        %Save core heatMap
        %heatMap = heatMap + (binCenter/sampleRate);
        
        %Record Time
        %time(nFrames,1) = i/videoReader.FrameRate - startFrame/videoReader.FrameRate;
        
        
        %Identify center location
        s = regionprops(bwlabel(center),diffFrame, 'weightedCentroid');
        c = [s.WeightedCentroid];
        xc = round(s(1).WeightedCentroid(1));
        yc = round(s(1).WeightedCentroid(2));
        
        %Record center location
        posCenter(nFrames,1) = xc;
        posCenter(nFrames,2) = height - yc;
        
        %Show center location in red
        %         rgbframe(yc-5:yc+5,xc-5:xc+5,1) = 255;
        %         rgbframe(yc-5:yc+5,xc-5:xc+5,2) = 0;
        %         rgbframe(yc-5:yc+5,xc-5:xc+5,3) = 0;
        
        %Identify tail and nose location
        try
            %Identify tail
            t = bwdistgeodesic(body,xc,yc,'chessboard');
            [maxt,indt] = max(t(:));
            [yt xt] = ind2sub(size(t),indt);
            
            %Identify head
            n = bwdistgeodesic(body,xt,yt,'chessboard');
            [maxn,indn] = max(n(:));
            [yh xh] = ind2sub(size(n),indn);
            
            %Record tail and head location
            posTail(nFrames,1) = xt;
            posTail(nFrames,2) = height - yt;
            posHead(nFrames,1) = xh;
            posHead(nFrames,2) = height - yh;
            
            %Show tail location in green
            %             rgbframe(yt-5:yt+5,xt-5:xt+5,1) = 0;
            %             rgbframe(yt-5:yt+5,xt-5:xt+5,2) = 255;
            %             rgbframe(yt-5:yt+5,xt-5:xt+5,3) = 0;
            
            %Show nose location in blue
            %             rgbframe(yh-5:yh+5,xh-5:xh+5,1) = 0;
            %             rgbframe(yh-5:yh+5,xh-5:xh+5,2) = 0;
            %             rgbframe(yh-5:yh+5,xh-5:xh+5,3) = 255;
        catch
            disp(['COULD NOT IDENTIFY HEAD OR TAIL IN FRAME ' num2str(i-startFrame) ' OF ' name]);
        end
        
        %Output Video
        %         frameSize = size(rgbframe);
        %         if frameSize(1) == height && frameSize(2) == width
        %             %writeVideo(videoWriter,diffFrame)); %background subtracted image
        %             %writeVideo(videoWriter,uint8(center*256)); %binary image
        %             writeVideo(videoWriter,rgbframe); %Original frame
        
        %     end
        
        %Display Stage of Processing
        if mod(nFrames,100) == 0
            disp([name ' Frame ' num2str(nFrames) ' of ' num2str((stopFrame-startFrame)/stepSize)]);
        end
        
        nFrames = nFrames + 1;
    catch
        disp(['COULD NOT IDENTIFY BODY IN FRAME ' num2str(i)]);
    end
end