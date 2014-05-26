function [scale, px_Q_cm] = findTransform(cm_pts, px_pts)
%FINDTRANSFORM takes a set of corresponding 2-space vectors and finds a scaling factor and
%rotation matrix between the two systems. scale = px/cm
%cm_pts and px_pts both 2xm m- number of vectors
%sets the first vector in each coordinate system as the origin
O_px = px_pts(:,1);
%set the origin of the cm at the 40 cm hashmark
O_cm = cm_pts(:,1);
%vectors in pixels
v_px = px_pts(:,2:end)-O_px*ones(1,size(px_pts(:,2:end),2));
v_cm = cm_pts(:,2:end)-O_cm*ones(1,size(cm_pts(:,2:end),2));
%scale - pixels/cm
scale = sqrt(sum(v_px(:,end).^2))/sqrt(sum(v_cm(:,end).^2));
unit_px = normc(v_px);
unit_cm = normc(v_cm);
theta = acos(mean(dot(unit_px,unit_cm)));
%rotation matrix to take you from pixels to cm
cm_Q_px = [cos(theta), -sin(theta); sin(theta) cos(theta)];
px_Q_cm = cm_Q_px';

end