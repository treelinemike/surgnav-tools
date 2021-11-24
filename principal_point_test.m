% test principal point encoding/decoding in a pair of stereo images
% ideally rectification would produce a stereo pair with identical
% principal points (to each other, not to the pre-rectified images) s.t.
% disparity can be calculated by subtracting actual pixel x values 

% restart
close all; clear; clc;

% load images and stereo calibration parameters
im_L = imread('./L/L00000003.tif');
im_R = imread('./R/R00000003.tif');
load('stereoParams.mat');

% load principal points from calibration
pp_L = stereoParams.CameraParameters1.Intrinsics.PrincipalPoint;
pp_R = stereoParams.CameraParameters2.Intrinsics.PrincipalPoint;

% encode principal points in grayscale images
im_aug_L = encode_principalpoint(pp_L(1),pp_L(2),1280,720,255);
im_aug_R = encode_principalpoint(pp_R(1),pp_R(2),1280,720,255);

% rectify the grayscale stereo pair 
[rect_aug_L,rect_aug_R] = rectifyStereoImages(im_aug_L,im_aug_R,stereoParams,'OutputView','valid','FillValues',255);  % OutputView if 'full' or 'valid'

% find the tracer pixels in the rectified/undistorted stereo pair
pp_rect_L=decode_principalpoint(rect_aug_L);
pp_rect_R=decode_principalpoint(rect_aug_R);

% display results
figure;
set(gcf,'Position',[2.626000e+02 1.466000e+02 9.344000e+02 5.632000e+02]);
t = tiledlayout(2,2);
t.Padding = 'none';
t.TileSpacing = 'compact';
nexttile(1);
grid on; hold on; axis image;
imshow(im_aug_L);
plot(pp_L(1),pp_L(2),'o','MarkerSize',10,'LineWidth',3,'Color',[0 1 0.]);
pp=decode_principalpoint(im_aug_L);
plot(pp(1),pp(2),'r+','LineWidth',2);
% plot(0,0,'r+','LineWidth',2);
% plot(0.5,0.5,'r+','LineWidth',2);
% plot(1280.5,0.5,'r+','LineWidth',2);
% plot(0.5,720.5,'r+','LineWidth',2);
% plot(1,1,'r+','LineWidth',2);
nexttile(2);
grid on; hold on; axis image;
imshow(im_aug_R);
plot(pp_R(1),pp_R(2),'o','MarkerSize',10,'LineWidth',3,'Color',[0 1 0]);
pp=decode_principalpoint(im_aug_R);
plot(pp(1),pp(2),'r+','LineWidth',2);
nexttile(3);
grid on; hold on; axis image;
imshow(rect_aug_L);
plot(pp_rect_L(1),pp_rect_L(2),'r+','LineWidth',2);
nexttile(4);
grid on; hold on; axis image;
imshow(rect_aug_R);
plot(pp_rect_R(1),pp_rect_R(2),'r+','LineWidth',2);
