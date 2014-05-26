%Example script for importing video and correlating with motor data
%
% This script does three things:
% 1) It takes a video file of the cart on the air track and produces a time
% history of the position of the cart relative to the leftmost red number
% maker in the scene. See ../angle_cart_setup.pdf for a visual.
%
% 2) It extracts data from a tab-delimited text file of motor data with 5 columns in the
% format defined by ../Experiment descriptions.txt. It synchs this data with the video. 
%
% 3) It goes frame-by-frame through the video, calibrates a
% pixel-to-centimeter conversion based on the 10cm marks on the air track
% and finds the x position of the cart along the track.
%
%
%
%

tic;
videoObj15 = VideoReader('fifteen deg test.MP4','Tag','degrees: 15');
motorFile =  'fifteen deg test.txt';
%frames of interest (from looking at video - first frame is when motor
%starts spinning)
spinStartFrame = 526; %when the motor starts spinning for the first time
spinStopFrame = 799; %end of 
%read the video data into 4D matrix (r-g-b-frame)
video = read(videoObj15,[spinStartFrame, spinStopFrame]);
toc
fps = videoObj15.Framerate; %frames/second
%% Get motor data and put it in a useful form
motorData = importMotorData(motorFile);

 
%% Synch up video data and motor data

%note that in this example, the startframe for the interval and the frame
%where the magnet starts spinning for the first time are the same. This is
%not necessarily the case.
[newMotorData, t_cart] =  synchMotorVideo(motorData,spinStartFrame, spinStopFrame, fps,spinStartFrame);
%% Find timeseries of left side of cart
%region of interest for finding reference points (the track)
%The video is 720x1200, so this ROI looks at the strip of 120 pixels at the
%bottom of the picture where the 
roi = [600 720; 1 1200]; 
%a and b say the frame size, c = 3 because the video is rgb d= number of
%frames
[a,b,c,d] = size(video);
%load the color markers for the red parts
%or use the experimental values
%load('color_marker_values.mat');
%experimentally determined hue and saturation for the red on the cart:
color_markers = [143.864285714286,132.885714285714];
%set the threshold for what is defined as 'red' by the algorithm
thresh = 6; 
%number of red blobs to look for
nBlobs = 3;
%set the separation between the blobs in cm
markerSep = 10;
%find the x position (with respect to track) of the cart for each frame
x_cart = zeros(1,d);

%iterate through all the frames in the video
for i = 1:d
    %find a point on the left side of the cart in pixel coordinates
    leftPt = cartLeft(rgb2gray(video(:,:,:,i)));
    %find the centers of the three biggest reddest 
    % objects in the frame, which should be the 10 cm markers
    centroids = findColoredBlobs(video(:,:,:,i), color_markers,thresh,nBlobs,roi);
    %positions of the red markers in cm from the left one
    v_cm2 = [0:(size(centroids,2)-1);zeros(1,size(centroids,2))]*markerSep;
    %find the scale factor and rotation matrix between a reference frame in
    %cm and oriented with the track and the reference frame in pixels and
    %oriented with the video
    [scale, cm_Q_px] = findTransform(v_cm2, centroids);
    %the origins of both the pixel and cm frame
    O_cm = [0;0]; O_px = centroids(:,1);
    % the rotiation matrix that takes you from cm to pixel frame is
    % the transpose of the rotation matrix that takes you from pixel to cm
    % frame
    px_Q_cm = cm_Q_px';
    %convert the left side of cart point to cm frame
    left_cm = transformPxCm(leftPt,scale,px_Q_cm,O_cm,O_px,'px2cm');
    % grab the x component of the left side of the cart - this will
    % correspond to the x position along the track
    left_cm_x = [left_cm(1,:);0];
    x_cart(i) = left_cm(1);
    
%    % plot stuff for debugging
%     left_cm_px = transformPxCm(left_cm_x,scale,px_Q_cm,O_cm,O_px,'cm2px');
%     
%     figure(1);
%     imshow(video(:,:,:,i)); hold on;
%     plot(centroids(1,:),centroids(2,:),'rx');
%     plot(leftPt(1),leftPt(2),'gx');
%     text(leftPt(1),leftPt(2),num2str(left_cm(1)),'Color','g');
%     hold off
%     drawnow;
end
save('15DegAnalyzedData.mat','t_cart','x_cart',...
    'newMotorData','spinStartFrame','spinStopFrame');
% Plot the results
figure(1); clf;
subplot(211)
plot(t_cart,x_cart);
legend('cart position');ylabel('position (cm)');
subplot(212);
plot(newMotorData.time,newMotorData.M1,newMotorData.time,newMotorData.M2);
legend('M1 spin','M2 spin');
xlabel('time (s)');ylabel('Motor speed - % duty cycle');