%% find left side of object for several frames
%read in the video
% videoObj90 = VideoReader('90 degree test2.MP4','Tag','degrees: 90');
% videoFrame90 = read(videoObj90,[500 550]);
% %load the color markers for the red parts
% load('color_marker_values.mat');
% %set the threshold for what is defined as 'red' by the algorithm
% thresh = 6; 
% %number of red blobs to look for
% nBlobs = 3;
% %set the separation between the blobs in cm
% markerSep = 10;
% %get the size of videoFrame90
% [a,b,c,d] = size(videoFrame90);
roi = [600 720; 1 1200];
for i = 1:d
    leftPt = cartLeft(rgb2gray(videoFrame90(:,:,:,i)));
    centroids = findColoredBlobs(videoFrame90(:,:,:,i), color_markers,thresh,nBlobs,roi);
    v_cm2 = [0:(size(centroids,2)-1);zeros(1,size(centroids,2))]*markerSep;
    [scale, cm_Q_px] = findTransform(v_cm2, centroids);
    O_cm = [0;0]; O_px = centroids(:,1);
    px_Q_cm = cm_Q_px';
    left_cm = transformPxCm(leftPt,scale,px_Q_cm,O_cm,O_px,'px2cm');
    left_cm_x = [left_cm(1,:);0];
    left_cm_px = transformPxCm(left_cm_x,scale,px_Q_cm,O_cm,O_px,'cm2px');
    
    %plot stuff
    figure(1);
    imshow(videoFrame90(:,:,:,i)); hold on;
    plot(centroids(1,:),centroids(2,:),'rx');
    plot(leftPt(1),leftPt(2),'gx');
    text(leftPt(1),leftPt(2),num2str(left_cm(1)),'Color','g');
    hold off
    drawnow;
end

