% slicer_seg_extract.m
%
% Extract binary segmentation masks for each volume slice from
% an NRRD file generated by 3D Slicer, writing masks as individual image
% files. Uses nrrdinfo() and nrrdread() from *new* MATLAB Medical Imaging
% Toolbox; however similar functionality is avaialble on the MATLAB File
% Exchange: https://www.mathworks.com/matlabcentral/fileexchange/66645-nrrd-nhdr-reader-and-writer
% We had previously used functions from the link above, but are now porting
% to the native MATLAB functions for robustness and future compatibility.
% 
% Author: M. Kokko
% Updated: 31-Jul-2023

% restart
close all; clear; clc;

% options
show_visualizaton = true;
seg_filename = 'Segmentation.seg.nrrd';
vol_filename = '3 mm 1R.nrrd';
desired_seg_name = 'CTV-D.Shen';
seg_mask_extension = 'png';
seg_mask_folder = 'mask_pngs';

% load segment header info and data
seg_info = nrrdinfo(seg_filename);
seg_num_slices = seg_info.ImageSize(3);
seg_data = nrrdread(seg_filename);

% load volume header info and data
vol_info = nrrdinfo(vol_filename);
vol_num_slices = vol_info.ImageSize(3);
vol_data = nrrdread(vol_filename);

% check that segmentation and volume stacks have same number of slices
assert(seg_num_slices == vol_num_slices,'Segmentation slice count does not match volume stack!');

% generate a table of segment info
% because NRRD header isn't set up for easy parsing!
% assuming these are always packed in order starting at zero...
seg_num = 0;
found_all_segs = false;
all_fields = fields(seg_info.RawAttributes);
seg_tab = cell2table(cell(0,5),'VariableNames',{'seg_num','seg_name','seg_layer','seg_value','seg_color'});
while(~found_all_segs)
    seg_prefix   = sprintf('segment%d_',seg_num);
    field_name   = [seg_prefix 'name'];
    field_layer  = [seg_prefix 'layer'];
    field_value  = [seg_prefix 'labelvalue'];
    field_color  = [seg_prefix 'color'];

    if(isfield(seg_info.RawAttributes,field_name))

        % get segment color as an array
        [tok,mat] = regexp(seg_info.RawAttributes.(field_color),'([0-9\.]+) ([0-9\.]+) ([0-9\.]+)','tokens','match');
        if(~isempty(tok))
            color_array = [str2num(tok{1}{1}) str2num(tok{1}{2}) str2num(tok{1}{3})];
        else
            error('Could not parse color array!');
        end

        % add this segment to our table
        seg_tab = [ seg_tab; ...
            {seg_num, ...
            seg_info.RawAttributes.(field_name), ...
            str2num(seg_info.RawAttributes.(field_layer)), ...
            str2num(seg_info.RawAttributes.(field_value)), ...
            color_array}
            ];

        % increment segment counter
        seg_num = seg_num + 1;
    else
        found_all_segs = true;
    end
end

% show the segment table in case we need to debug (i.e. find actual segment
% name...)
seg_tab

% identify parameters associated with the chosen segment
seg_tab_idx = find(strcmp(seg_tab.seg_name,desired_seg_name));
assert(numel(seg_tab_idx) == 1,'Did not find exactly one matching segment name!');
seg_layer = seg_tab.seg_layer(seg_tab_idx);
seg_value = seg_tab.seg_value(seg_tab_idx);
seg_color = seg_tab.seg_color(seg_tab_idx,:);

% create a folder for segmentation masks if needed
if(~isfolder(seg_mask_folder))
    mkdir(seg_mask_folder);
end

% iterate through all slices
% producing both raw pngs and overlays
if(show_visualizaton)
    figure;
end
for slice_idx = 1:seg_num_slices

    % extract and save appropriate segmentation mask
    seg_map = (seg_data(:,:,slice_idx,seg_layer+1) == seg_value);
    imwrite(seg_map,fullfile(seg_mask_folder,sprintf('%s_%04d.%s',desired_seg_name,slice_idx,seg_mask_extension)));  % note: now 1-indexed: subtract 1 from slice_idx if you want...

    % produce an overlay image for verification
    if(show_visualizaton)
        img_raw = double(vol_data(:,:,slice_idx));
        img_raw = img_raw - min(img_raw(:));
        img_raw = uint8( img_raw * (255/max(img_raw(:)))  );
        img_overlay = imoverlay(img_raw,seg_map,seg_color);
        imshow(img_overlay,[]);
        drawnow;
        pause(0.01);
    end

end
