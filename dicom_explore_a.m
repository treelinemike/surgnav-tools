% restart
close; clear; clc; 

% options
filename = 'H:\CT\31584-010\CT 9001-9004\900403';
minHUScaleVal = -208;
maxHUScaleVal = 218;

% load DICOM info
dinf = dicominfo(filename);

% load DICOM image and adjust grey values
im = dicomread(filename);
im = double(im)*dinf.RescaleSlope + dinf.RescaleIntercept;  % will need coversion to uint8 to be standardized!
im = uint8((im-minHUScaleVal)*(255/(maxHUScaleVal-minHUScaleVal))); % rescale HU to grayscale based on a "pretty good" mapping identified in Mimics

% show image
imshow(im);

% extract and show relevant metadata
seriesNo = dinf.SeriesNumber
seriesDate = dinf.SeriesDate
acqTime = dinf.AcquisitionTime
imPosPt = dinf.ImagePositionPatient(3)