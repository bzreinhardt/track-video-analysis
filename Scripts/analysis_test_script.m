% To read video into matlab:
% 
% Create a reader object from the path to a video file:
% 
% xyloObj = mmreader('xylophone.mpg');
% 
% Read frame#index from the video into a matrix (or 3d matrix if it's a color image):
% 
% video_frame = read(xyloObj, index);
% 
% There are also a bunch of useful properties of the video object like:
% 
% nFrames = xyloObj.NumberOfFrames;
% vidHeight = xyloObj.Height;
% vidWidth = xyloObj.Width;
% 
% For tracking a cart that is translating, but not rotating, 
% I would do image registration via cross correlation of an image patch. 
% The principal here is that you have an image patch of the object you want to track, 
% and each frame, you do a 2d cross correlation of that patch with the current 
% frame to see where in x,y it lines up the best. Info about how to do that 
% is can be found by searching 
% "Registering an Image Using Normalized Cross-Correlation" in the matlab help.
% 
% % I would load up frame #1 and have the user click out a rectangle 
% (using [x,y] = ginput(2)) to define the patch for your cart. 
% Then, at each frame, have matlab do the cross-correlation to 
% figure out where the patch of the cart best lines up.
% % 
% % Depending on how robust that is, you could do a filter or some other 
% estimator that takes into account a prediction of where the cart will 
% be from the previous step as some kind of bayesian prior or something.
videoObj90 = VideoReader('90 degree test2.MP4','Tag','degrees: 90');
% %The read method returns a H-by-W-by-B-by-F matrix, video, 
% where H is the image frame height, W is the image frame width, B 
% is the number of bands in the image (for example, 3 for RGB), 
% and F is the number of frames read.
videoFrame90 = read(videoObj90,[500 550]);
%[X,map] = imread('vlcsnap-2014-05-12-18h31m53s28.png');
figure(1);
imshow(videoFrame90(:,:,:,1));
figure(2);
imshow(videoFrame90(:,:,:,2));
%%
% $x^2+e^{\pi i}$
%Find Image Rotation and Scale Using Automated Feature Matching

%turn video into black and white
[a b c d] = size(videoFrame90);
grayVideo90 = zeros(a,b,d);
for i = 1:d
grayVideo90(:,:,i) = rgb2gray(videoFrame90(:,:,:,i));
end
imshow(grayVideo90(:,:,2),[]);
%make image black and white 
washedImage = imextendedmax(grayVideo90(:,:,2),210);
%flip black/white so that black cart is now white
flippedImg = ~washedImage;
%remove small features
sedisk = strel('disk',50);
noSmallStructures = imopen(flippedImg, sedisk);


%find the area and bounding boxes for the remaining features
STATS = regionprops(noSmallStructures,'Area','Extrema');
%assume the cart will be the biggest feature
areas = zeros(size(STATS,1),1);
for i = 1:size(STATS,1)
    areas(i) = STATS(i).Area;
end
    
[bigA bigI] = max(areas);
%find the bounding box of the cart
cartExtrema = STATS(bigI).Extrema;
%the back of cart should be captured by the lin between the 'left bottom'
%and 'left top' points in the exrema. These correspond to Extrema(7:8,:)
% imshow(noSmallStructures,[]); hold on;
% patch(cartExtrema(:,1),cartExtrema(:,2),'r');
% plot(cartExtrema(7:8,1),cartExtrema(7:8,2),'g','LineWidth',10);

%read in frames from the video object
videoFrame90 = read(videoObj90,[500 550]);
%turn the frames into gray
[a b c d] = size(videoFrame90);
grayVideo90 = zeros(a,b,d);
for i = 1:d
grayVideo90(:,:,i) = rgb2gray(videoFrame90(:,:,:,i));
end



testImg = grayVideo90(:,:,1);
[center, radius] = imfindcircles(testImg,[9 10],'Sensitivity',0.9);
imshow(testImg,[]);hold on;
viscircles(center,radius);

rotcoords = cpselect(videoFrame90(:,:,:,1),videoFrame90(:,:,:,2));
movingPoints = [315.000000000000,655.625000000000;661.500000000000,669.875000000000];
%10 cm in X direction between the two identified points
stationaryPoints = [316.500000000000,655.625000000000;662.250000000000,669.125000000000];

imshow(testImg,[]);
hold on;
plot(stationaryPoints(:,1),stationaryPoints(:,2),'g');

%set the origin at the first pixel point in the middle of the 40 cm '0'
O_px = stationaryPoints(1,:)';
%set the origin of the cm at the 40 cm hashmark
O_cm = [0.3;0];
%scaling factor between pixels and cm - pixels/cm


v_px = stationaryPoints(2,:)'-O_px;
v_cm = [10;0]-O_cm;
scale = sqrt(sum(v_px.^2))/sqrt(sum(v_cm.^2));

unit_px = v_px/norm(v_px);
unit_cm = [1;0];
theta = acos(dot(unit_px,unit_cm));
%rotation matrix to take you from pixels to cm
cm_Q_px = [cos(theta), -sin(theta); sin(theta) cos(theta)];
px_Q_cm = cm_Q_px';

v2_cm = [1;0];
test = scale*px_Q_cm'*(v2_cm-O_cm)+O_px;
plot(test(1),test(2),'rx');

v3_cm = [4;0];
test = scale*px_Q_cm'*(v3_cm-O_cm)+O_px;
plot(test(1),test(2),'yx');

cm_pos = zeros(2,size(grayVideo90,3));
corners = zeros(2, size(grayVideo90,3));

%find left side of object
for i = 1:size(grayVideo90,3)
    corners(:,i) = cartLeft(grayVideo90(:,:,i));
    cm_pos(:,i) = cm_Q_px*(corners(:,i)-O_px)/scale +O_cm;
    imshow(grayVideo90(:,:,i),[]); hold on;
    plot(corners(1,i),corners(1,i),'gx');
    text(corners(1,i),corners(1,i),num2str(cm_pos(1,i)),'Color','g');
    hold off
    drawnow;
end
%% Find the color values for the red we're interested in 
%trying to ID other feature points
[a b c d] = size(videoFrame90);
%tr
%make image black and white 
washedImage = imextendedmin(grayVideo90(:,:,1),100);
imshow(washedImage);
%Idea, grab red parts
colorImage = videoFrame90(:,:,:,1);
colorImageR = colorImage(:,:,1);
colorImageG = colorImage(:,:,2);
colorImageB = colorImage(:,:,3);

figure(1);imshow(colorImageR);
figure(2);imshow(colorImageG);
figure(3);imshow(colorImageB);

redRegion = roipoly(colorImage);
roiPts = [634 660;632 677;641 678;641 662];
imshow(redRegion);
%convert the image from rgb to luminosity, a, b
cform = makecform('srgb2lab');
lab_image = applycform(colorImage,cform);

nColors = 1;
a = lab_image(:,:,2);
b = lab_image(:,:,3);

color_markers = repmat(0, [nColors, 2]);

color_markers(1,1) = mean2(a(redRegion(:,:)));
color_markers(1,2) = mean2(b(redRegion(:,:)));
%% Find the centroids of the 3 biggest red regions
color_labels = [0,1];
a = double(a);
b = double(b);
distance = repmat(0,[size(a),nColors]);

for count = 1:nColors
    distance(:,:,count) = ( ( a - color_markers(count,1)).^2 + ...
                            (b - color_markers(count,2)).^2).^0.5;
end
%threshold the image to get only the red objects
thresh = 6;

label = distance;
label(label >= thresh) = 0;

rgb_label = repmat(label, [ 1 1 3]);
color = colorImage;
color(rgb_label == 0) = 0;
imshow(color);

%convert to b/w
bwRed = rgb2gray(color);
washedRed = imextendedmin(bwRed,0);
%flip black to white
flippedImg = ~washedRed;
%get only the large objects
sedisk = strel('disk',1);
noSmallStructures = imopen(flippedImg, sedisk);
imshow(noSmallStructures);
%find the centroids of the red objects
 STATS = regionprops(noSmallStructures,'Area','Centroid');
 numMarkers = 3;
statCell = struct2cell(STATS);
statCell = statCell';
orderedStatCell = sortrows(statCell,1);

bigBlobs = orderedStatCell((end-numMarkers+1):end,:);
centroids = cell2mat(bigBlobs(:,2))';
imshow(bwRed);
hold on
plot(centroids(1,:),centroids(2,:),'bx','MarkerSize',20);
%% From the centroids, find the transform matrix between cm and px
markerSep = 10;
%for now, just have the scale be the first marker to third marker/20
 %set the origin at the first centroid of the big red blobs
 %sort the centroids by pixel X coordinate 
 centroids = sortrows(centroids',1)';
O_px = centroids(:,1);
%set the origin of the cm at the 40 cm hashmark
O_cm = [0;0];
%vectors in pixels
v_px = centroids(:,2:end)-O_px*ones(1,size(centroids(:,2:end),2));
v_cm = [1:(numMarkers-1);zeros(1,size(centroids(:,2:end),2))]*markerSep;
%scale - pixels/cm
scale = sqrt(sum(v_px(:,end).^2))/sqrt(sum(v_cm(:,end).^2));
unit_px = normc(v_px);
unit_cm = normc(v_cm);
cm_px = v_px/scale;
Q_test = v_cm*pinv(cm_px);

theta = acos(mean(dot(unit_px,unit_cm)));
%rotation matrix to take you from pixels to cm
cm_Q_px = [cos(theta), -sin(theta); sin(theta) cos(theta)];
px_Q_cm = cm_Q_px';
   
 v2_cm = [1;0];
test = scale*px_Q_cm'*(v2_cm-O_cm)+O_px;
plot(test(1),test(2),'rx');

v3_cm = [4;0];
test = scale*px_Q_cm'*(v3_cm-O_cm)+O_px;
plot(test(1),test(2),'yx'); 
nBlobs = 3;

%% testing functions
markerSep = 10;
nBlobs = 3;
thresh = 6;
centroids2 = findColoredBlobs(colorImage, color_markers,thresh,nBlobs);

v_cm2 = [0:(size(centroids2,2)-1);zeros(1,size(centroids2,2))]*markerSep;
[scale, cm_Q_px] = findTransform(v_cm2, centroids2);
px_Q_cm = cm_Q_px';
O_cm = v_cm2(:,1); O_px = centroids2(:,1);
testVec_cm = [1:10;zeros(1,10)];
testVec_px = scale*px_Q_cm*(testVec_cm-O_cm*ones(1,size(testVec_cm,2)))+O_px*ones(1,size(testVec_cm,2));

imshow(colorImage); hold on;
plot(testVec_px(1,:),testVec_px(2,:),'rx');

leftPt = cartLeft(rgb2gray(colorImage));

plot(leftPt(1),leftPt(2),'gx');
left_cm = transformPxCm(leftPt,scale,px_Q_cm,O_cm,O_px,'px2cm');
left_cm_x = [left_cm(1,:);0];
left_cm_px = transformPxCm(left_cm_x,scale,px_Q_cm,O_cm,O_px,'cm2px');

plot(left_cm_px(1),left_cm_px(2),'yx','MarkerSize',40);

%% find left side of object for several frames
%read in the video
videoFrame90 = read(videoObj90,[500 550]);
%load the color markers for the red parts
load('color_marker_values.mat');
%set the threshold for what is defined as 'red' by the algorithm
thresh = 6; 
%number of red blobs to look for
nBlobs = 3;
%set the separation between the blobs in cm
markerSep = 10;
%get the size of videoFrame90
[a,b,c,d] = size(videoFrame90);

for i = 1:d
    leftPt = cartLeft(rgb2gray(videoFrame90(:,:,:,i)));
    centroids = findColoredBlobs(videoFrame90(:,:,:,i), color_markers,thresh,nBlobs);
    v_cm2 = [0:(size(centroids2,2)-1);zeros(1,size(centroids2,2))]*markerSep;
    [scale, cm_Q_px] = findTransform(v_cm2, centroids2);
    O_cm = [0;0]; O_px = centroids(:,1);
    left_cm = transformPxCm(leftPt,scale,px_Q_cm,O_cm,O_px,'px2cm');
    left_cm_x = [left_cm(1,:);0];
    left_cm_px = transformPxCm(left_cm_x,scale,px_Q_cm,O_cm,O_px,'cm2px');
    
    %plot stuff
    imshow(videoFrame90(:,:,:,i)); hold on;
    plot(centroids(1,:),centroids(2,:),'rx');
    plot(leftPt(1),leftPt(2),'gx');
    text(leftPt(1),leftPt(2),num2str(left_cm(1)),'Color','g');
    hold off
    drawnow;
end

