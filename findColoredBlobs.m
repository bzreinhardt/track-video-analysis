function centroids = findColoredBlobs(img, colorMarkers,thresh,nBlobs,roi)
%finds the centroids of the n biggest colored blobs in the image
%img - an image
%colorMarkers [a1,b1;a2,b2...] values from the luminosity a b form of the
%color of interest
%thresh - the threshold amount of the color that must be present to
%register
%nBlobs - number of blobs to look for
% roi - region of interest - 2x2 range of pixel indicies of interest for
% the identifiers to avoid spurrious id's - remember +y is down [ymin
% ymax; xmin xmax];
cform = makecform('srgb2lab');
clip_img = img(roi(1,1):roi(1,2),roi(2,1):roi(2,2),:);
lab_image = applycform(clip_img,cform);

nColors = 1;
a = lab_image(:,:,2);
b = lab_image(:,:,3);
a = double(a);
b = double(b);

ncolors = size(colorMarkers,1);
distance = zeros(size(a,1),size(a,2),ncolors);

for count = 1:nColors
    distance(:,:,count) = ( ( a - colorMarkers(count,1)).^2 + ...
                            (b - colorMarkers(count,2)).^2).^0.5;
end
%threshold away everything but the colored objects
label = distance;
label(label >= thresh) = 0;
rgb_label = repmat(label, [ 1 1 3]);
clip_img(rgb_label == 0) = 0;

%convert to b/w
bwRed = rgb2gray(clip_img);
washedRed = imextendedmin(bwRed,0);
%flip black to white - we want to see white objects
flippedImg = ~washedRed;
%bloat the pixels so the red sections can connect
bloat_structure = strel('rectangle',[10,12]);
bloatImg = imdilate(flippedImg,bloat_structure);
%get only the large objects
sedisk = strel('disk',3);
noSmallStructures = imopen(bloatImg, sedisk);
%display for debugging

% figure(2);imshow(noSmallStructures); 
%find the centroids of the red objects
 STATS = regionprops(noSmallStructures,'Area','Centroid');
%do some rearranging to get a cell array with the biggest objects at the
%end
statCell = struct2cell(STATS);
statCell = statCell';
orderedStatCell = sortrows(statCell,1);
%take the biggest objects
bigBlobs = orderedStatCell((end-nBlobs+1):end,:);
%output the centroids of the biggest objects
centroids = cell2mat(bigBlobs(:,2))';
%display for debugging
% figure(10);clf;
% mask = uint8(noSmallStructures);
% newMask(:,:,1) = mask; newMask(:,:,2) = mask; newMask(:,:,3) = mask;
% test = newMask .* img(roi(1,1):roi(1,2),roi(2,1):roi(2,2),:);
% imshow(test); hold on
% plot(centroids(1,:),centroids(2,:),'gx','MarkerSize',30,'LineWidth',5);
% order the centroids from smallest X coordinate to biggest
centroids = sortrows(centroids',1)';
%reconstruct original coordinates for complete image
xShift = roi(2,1)-1; yShift = roi(1,1)-1;
centroids = centroids + [xShift;yShift] * ones(1,size(centroids,2));
end