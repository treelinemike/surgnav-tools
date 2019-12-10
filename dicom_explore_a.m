close; clear; clc; 
filename = '632116';
im = dicomread(filename);
im1 = im-min(im(:));
im2 = double(im1)/double(max(im1(:)));
imshow(im2);

a = dicominfo(filename);
seriesNo = a.SeriesNumber
