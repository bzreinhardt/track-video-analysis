%Test script for importing video and correlating with motor data
videoObj15 = VideoReader('fifteen deg test.MP4','Tag','degrees: 15');

%% Get motor data and put it in a useful form
tData = tdfread('fifteen deg test.txt'); %motor data from arduino
%create names of new fields
fields = fieldnames(tData);
oldtime = fields(1);
oldM1R = fields(2);
oldM1L = fields(3);
oldM2R = fields(4);
oldM2L = fields(5);
%create renamed data
tData.time = tData.(oldtime{:});
tData.M1L = tData.(oldM1L{:});
tData.M1R = tData.(oldM1R{:});
tData.M2L = tData.(oldM2L{:});
tData.M2R = tData.(oldM2R{:});
%get rid of old data
tData = rmfield(tData,(oldtime{:}));
tData = rmfield(tData,(oldM1L{:}));
tData = rmfield(tData,(oldM1R{:}));
tData = rmfield(tData,(oldM2L{:}));
tData = rmfield(tData,(oldM2R{:}));

 

%% Synch up video data and motor data
spinStartFrame = 526; %when the motor starts spinning for the first time
spinStopFrame = 799; %end of 

fps = videoObj15.Framerate; %frames/second
t_cart = (0:(spinStopFrame-spinStartFrame))/fps;
t_end = max(t_cart);

dt = 1/fps;  %timestep in cart data

video = read(videoObj15,[spinStartFrame, spinStopFrame]);

% create new structure starting when the video starts (when motor starts)


tData.time = 1E-3*(tData.time-tData.time(1));
spinStopInd = find(tData.time > t_end,1);
synchData = tData;
fields = fieldnames(synchData);
for i = 1:numel(fields)
    data = synchData.(fields{i});
  synchData.(fields{i}) = data(spinStartInd:spinStartInd+spinStopInd);
  
end
synchData.time = synchData.time- synchData.time(1);
%set first motor data point to zero and convert time to seconds 


%combine data into single motor commands for each motor
M1 = (synchData.M1L-synchData.M1R)/255;
M2 = (synchData.M1R-synchData.M1L)/255;

%% Find timeseries of left side of cart
%region of interest for finding reference points (the track)
roi = [600 720; 1 1200];
[a,b,c,d] = size(video);
%load the color markers for the red parts
load('color_marker_values.mat');
%set the threshold for what is defined as 'red' by the algorithm
thresh = 6; 
%number of red blobs to look for
nBlobs = 3;
%set the separation between the blobs in cm
markerSep = 10;
%find the x position (with respect to track) of the cart for each frame
x_cart = zeros(1,d);

for i = 1:d
    leftPt = cartLeft(rgb2gray(video(:,:,:,i)));
    centroids = findColoredBlobs(video(:,:,:,i), color_markers,thresh,nBlobs,roi);
    v_cm2 = [0:(size(centroids,2)-1);zeros(1,size(centroids,2))]*markerSep;
    [scale, cm_Q_px] = findTransform(v_cm2, centroids);
    O_cm = [0;0]; O_px = centroids(:,1);
    px_Q_cm = cm_Q_px';
    left_cm = transformPxCm(leftPt,scale,px_Q_cm,O_cm,O_px,'px2cm');
    left_cm_x = [left_cm(1,:);0];
    left_cm_px = transformPxCm(left_cm_x,scale,px_Q_cm,O_cm,O_px,'cm2px');
    x_cart(i) = left_cm(1);
    %plot stuff
    figure(1);
    imshow(video(:,:,:,i)); hold on;
    plot(centroids(1,:),centroids(2,:),'rx');
    plot(leftPt(1),leftPt(2),'gx');
    text(leftPt(1),leftPt(2),num2str(left_cm(1)),'Color','g');
    hold off
    drawnow;
end

windowSize = 10;
%differentiate position
x_cart_smooth = filter(ones(1,windowSize)/windowSize,1,x_cart);
v_cart = (x_cart-[0,x_cart(1:end-1)])/dt;
%smooth result

v_cart_smooth = filter(ones(1,windowSize)/windowSize,1,v_cart);
%differentiate velocity
a_cart = (v_cart_smooth-[0,v_cart_smooth(1:end-1)])/dt;
a_cart_smooth = filter(ones(1,windowSize)/windowSize,1,a_cart);
figure(1);clf; plot(t_cart,x_cart,t_cart,v_cart_smooth,t_cart,a_cart_smooth);
% Plot the results
figure(4); clf;
subplot(211)
plot(t_cart,x_cart);
legend('cart position');ylabel('position (cm)');
subplot(212);
plot(synchData.time,M1,synchData.time,M2);
legend('M1 spin','M2 spin');
xlabel('time (s)');ylabel('Motor speed - % duty cycle');