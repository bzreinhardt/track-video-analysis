function [newMotorData, t_cart] =  synchMotorVideo(motorData,startFrame, stopFrame, fps)
%synchMotorVideo modifies motor pwm time data to match up with the frames
%of interest in the video data
%
%INPUTS
% motorData - struct with fields time, M1R, M1L, M2R, M2L - assume time is
% in milliseconds
% startFrame and stopFrame - frame numbers that begin and end the region of
% interest
% fps - framerate of the video in frames per second 

%OUTPUTS
%newMotorData - struct with fields time, M1, M2 (M1L is + spin and M2R is +
%spin)
%t_cart - time vector associated with the frames of the video 

%% set the cart time data
t_cart = (0:(spinStopFrame-spinStartFrame))/fps;

end