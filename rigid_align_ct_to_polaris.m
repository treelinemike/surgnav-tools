function [TF,RMSE] = rigid_align_ct_to_polaris(ct_lab, ct_loc, polaris_lab, polaris_loc)

% storage
fid_set_ct = [];
fid_set_polaris = [];
fid_set_idx = [];

% check each unique label
all_polaris_labels = unique(polaris_lab);
for polaris_idx = 1:length(all_polaris_labels)

    % get polaris label and mask
    polaris_label = all_polaris_labels{polaris_idx};
    polaris_mask = cellfun(@(x)strcmp(x,polaris_label),polaris_lab);

    % does this fit the "fid xxx" format?
    [mat,tok] = regexp(polaris_label, '^fid\s+([0-9]+)$','match','tokens');
    if(numel(mat) == 1 && numel(tok) == 1)

        % is this label unique in polaris dataset?
        if(nnz(polaris_mask) ~= 1)
            error('FID label not unique in polaris dataset!');
        end

        % can we find this fiducial in the CT set?
        % desciption field from Slicer needs to be just the number
        fid_idx = str2double(tok{1}{1});
        fid_ct_mask = (ct_lab == fid_idx);
        switch(nnz(fid_ct_mask))
            case 0
                fprintf('Fiducial %d not found in CT dataset...\n',fid_idx);
            case 1
                % now we have a correspondence between polaris and CT fiducials
                % so add it to our list for registration

                % fiducial position in CT
                ct_xyz = ct_loc(fid_ct_mask,:);

                % fiducial position in polaris
                polaris_xyz = polaris_loc(polaris_mask,:);
                
                % update point sets
                fid_set_ct(end+1,:) = ct_xyz;
                fid_set_polaris(end+1,:) = polaris_xyz;
                fid_set_idx(end+1,:) = fid_idx;

            otherwise
                error('Fiducial %d not unique in CT dataset!',fid_idx);
        end
    end
end

% compute rigid registration
[p_new,TF,RMSE] = rigid_align_svd(fid_set_ct',fid_set_polaris');




end