% restart
close; clear; clc; 

% options
filename = "C:\Users\f002r5k\Downloads\2.25.118536877960140261913892053863663681705.dcm";
minHUScaleVal = -208;
maxHUScaleVal = 218;

% load DICOM info
dinf = dicominfo(filename);

% load DICOM image and adjust grey values
im_raw = dicomread(filename);
im = im_raw;
im = double(im)*dinf.RescaleSlope + dinf.RescaleIntercept;  % will need coversion to uint8 to be standardized!
im = uint8((im-minHUScaleVal)*(255/(maxHUScaleVal-minHUScaleVal))); % rescale HU to grayscale based on a "pretty good" mapping identified in Mimics

% show image
imshow(im);

% extract and show relevant metadata
% seriesDescrip = dinf.SeriesDescription
sliceThk =  dinf.SliceThickness
seriesNo = dinf.SeriesNumber
seriesDate = dinf.SeriesDate
acqTime = dinf.AcquisitionTime
imPosPt = dinf.ImagePositionPatient(3)
dinf.ImageOrientationPatient
% dinf.PatientID = 'Test01'
% dicomwrite(im_raw,'testdcm',dinf)