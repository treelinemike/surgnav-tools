close; clear; clc; 
filename = 'E:\901561\901563\901752';
im = dicomread(filename);
im1 = im-min(im(:));
im2 = double(im1)/double(max(im1(:)));
imshow(im2);

a = dicominfo(filename);
seriesNo = a.SeriesNumber
seriesDate = a.SeriesDate
acqTime = a.AcquisitionTime