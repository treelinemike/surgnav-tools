% assign Patient ID in DICOM series

% restart
close all; clear; clc;

% options
patient_id = 'A01';
study_id = '001';
series_id = '001';
doUseDCMExtension = false;
dicom_read_path = "G:\.shortcut-targets-by-id\1DXab6fRFPLxd5fj49tY3mc-NZnjbf0IM\STUDY Lymph Node\CTs\A1\A1 post_anon"
dicom_write_path = "C:\Users\f002r5k\Desktop\test"

% get list of presumed DICOM files in folder
allFilesInDir = dir(dicom_read_path);
allFilenames = {allFilesInDir.name};
if(doUseDCMExtension)
    filesWithDCMExtensionMask = contains(allFilenames,'.dcm');
    allFilenames = allFilenames(filesWithDCMExtensionMask);
else
    filesWithExtensionsMask = contains(allFilenames,'.');
    allFilenames(filesWithExtensionsMask) = [];
end

for file_idx = 1:length(allFilenames)
    fprintf('Processing file %d/%d',file_idx,length(allFilenames));
    read_filename = allFilenames{file_idx};
    read_filename_full = [char(dicom_read_path) '\' read_filename];
    im_raw = dicomread(read_filename_full);
    dinf = dicominfo(read_filename_full);
    fprintf('.');
    dinf.PatientID = patient_id;
    dinf.StudyID = study_id;
    dinf.StudyInstanceUID = study_id;
    dinf.SeriesInstanceUID = series_id;
    write_filename = ['updated_' read_filename];
    Write_filename_full = [char(dicom_write_path) '\' write_filename];    
    dicomwrite(im_raw,Write_filename_full,dinf);
    fprintf('.\n');
end
    