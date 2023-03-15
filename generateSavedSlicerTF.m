% Generate transform elements to be saved and imported into 3D slicer
% Inverse process of convertSavedSlicerTF()
function TF_fromparent_lps_elements = generateSavedSlicerTF(TF_toparent_ras)
    ras2lps = diag([-1 -1 1 1]);
    TF = inv(ras2lps*TF_toparent_ras*ras2lps);
    TF_fromparent_lps_elements = [reshape(transpose(TF(1:3,1:3)),9,1); TF(1:3,4)];
end