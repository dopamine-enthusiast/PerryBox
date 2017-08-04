Aquire an image from webcam

    set(vid_lat,'loggingmode','memory');
    start(vid_lat);
    trigger(vid_lat);
    pause(0.5);
    stop(vid_lat)
    set(vid_lat,'loggingmode','disk');
    f_avail=get(vid_lat,'FramesAvailable');
    [im_lat t_lat] = getdata(vid_lat,f_avail);
    base_image=im_lat(:,:,:,end);

show image in figure and use ginput to get user specified coordinates

    f1=figure;
    im_s1=size(base_image,1);
    im_s2=size(base_image,2);
    imshow(base_image);
    [x, y]=ginput;
    close(f1);
    
generate a 'mask' for the image base don user coordinates

    fh.ROI_ax=subplot('Position',[0.53 0.41 0.43 0.2]);
    x=round(x);y=round(y);
    ROI_mask=poly2mask(x,y,im_s1,im_s2);
    temp=base_image;
    temp(ROI_mask)=-100; %create mask
    imshow(temp)