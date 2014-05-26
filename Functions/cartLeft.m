function leftPt = cartLeft(frame)
%CARTLEFT takes a greyscale picture (NxM double matrix) and finds the
%coordinates, in pixels of the biggest, blackest thing in the image. 

%make image black and white 
washedImage = imextendedmax(frame,200);
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
    
[bigA, bigI] = max(areas);
%find the bounding box of the cart
cartExtrema = STATS(bigI).Extrema;
%the back of cart should be captured by the lin between the 'left bottom'
%and 'left top' points in the exrema. These correspond to Extrema(7:8,:)
leftPt = cartExtrema(7,:)';
end