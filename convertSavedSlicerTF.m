% Convert a saved 3D slicer transform from its silly output format
% back into what we'd expect given the display in the Slicer GUI
% 
% Realy Slicer displays transforms in RAS coordinates in the TO PARENT
% direction, but saves the FROM PARENT direction in LPS coordintes.
% This function therefore converts from LPS to RAS and then inverts to put
% a saved transform back into the RAS / TO PARENT configuration.
%
% This is not execptionally well documented and was a pain to figure out.
% Some references:
% https://slicer.readthedocs.io/en/latest/developer_guide/script_repository.html#convert-between-itk-and-slicer-linear-transforms
% https://discourse.slicer.org/t/transformation-matrix-ras-to-lps/19352/2
% https://slicer.readthedocs.io/en/latest/user_guide/modules/transforms.html#save-transform
%
% Input argument TF_fromparent_lps_elements is just a 
%
function TF_toparent_ras = convertSavedSlicerTF(TF_fromparent_lps_elements)
    if( ~isvector(TF_fromparent_lps_elements) || (numel(TF_fromparent_lps_elements) ~= 12) )
        error('Invalid input, must be a 12-element vector of elements saved by 3D Slicer.');
    end
    TF = [reshape(TF_fromparent_lps_elements(1:9),3,3)' TF_fromparent_lps_elements(10:12); 0 0 0 1];
    ras2lps = diag([-1 -1 1 1]);
    TF_toparent_ras = inv(ras2lps*TF*ras2lps);
end