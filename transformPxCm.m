function out = transformPxCm(pts, scale, px_Q_cm, O_cm, O_px, arg)
% points in 2 space to be transformed 2xm
%scale - scale factor in px/cm
% px_Q_cm - rotation matrix that transforms cm to px
% O_cm - origin point for the cm coordinates
% O_px - origin point for the px coordinates
% arg - string either cm2px or px2cm
if strcmp(arg,'cm2px') == 1
    out = scale*px_Q_cm*(pts-O_cm*ones(1,size(pts,2)))+O_px*ones(1,size(pts,2));
elseif strcmp(arg, 'px2cm') == 1
    out = 1/scale*px_Q_cm'*(pts-O_px*ones(1,size(pts,2)))+O_cm*ones(1,size(pts,2));
else
    warning('specify cm2px or px2cm');
    out = NaN;
end