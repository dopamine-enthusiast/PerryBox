function outcomes = pellet_detection(video)

    global ROI_mask
    
    fig = figure;
    hold on;
    outcomes = 1;       
    thresh = 0;
    current_frame = 1;

        while (((current_frame) <= size(video,4)) && outcomes == 1)

                im=rgb2gray(video(:,:,:,current_frame));
                base_image = rgb2gray(video(:,:,:,1));

                im2 = im;
                im2(~ROI_mask) = 0;
                im2 = im2(any(im2,2),:);
                im2 = im2';
                im2 = im2(any(im2,2),:);
                im2 = im2';

                base_image(~ROI_mask) = 0;
                base_image = base_image(any(base_image,2),:);
                base_image = base_image';
                base_image = base_image(any(base_image,2),:);
                base_image = base_image';

                im3=imsubtract(im2,base_image);
                im3=medfilt2(im3,[2 2]); % cleans image with diff filter           
                im3 = im2bw(im3, 0.25);

                subplot(2,1,1)
                im(ROI_mask)=-100; %create mask
                imshow(im);

                subplot(2,1,2)
                imshow(im3);  

                thresh = thresh + nnz(im3);
                
                if thresh > 100
                    outcomes = 0;
                end

                title(thresh);
                current_frame = current_frame + 1;
                pause(0.001)            
        end
   hold off;
   close(fig);
   
end