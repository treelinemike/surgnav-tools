% remove vertices from a mesh
% also removes any face that includes one or more of the removed vertices
%
% f_in = n x 3 triangular face descriptions
% v_in = m x 3 vertex definitions in R^3 
% v_to_remove: list of vertices to remove (either list of indices or logical mask?)
%
function [f_out, v_out] = makmesh_removeVertices(f_in, v_in, v_to_remove)

% v_to_remove = [2];
% 
% 
% v_in = [   0.5 0.2 0.4; 
%         0.12, 4.2, 5.2;
%         3.2, 3.3, 1.2;
%         1.1, 3.3, 5.6;
%         3.6, 7.8 0.1;
%         ];
% 
% f_in = [1 2 3;
%     2 3 4;
%     5 3 4;
%     4 3 1;
%     2 4 5;
%     1 3 4;    
%     ];


% convert logical mask to indices
if(islogical(v_to_remove))
    v_to_remove = find(v_to_remove);
end

% create a mapping vector such that:
% - the index of any given element in the vector represents the NEW vertex index
% - the value at the index location represents the OLD vertex index
v_num_new = 1:size(v_in,1);
v_num_new(v_to_remove) = [];

% map old vertex indices to new vertex indices
% leaving any eliminated vertices as NaN
f_out = nan(size(f_in));
for v_idx = 1:length(v_num_new)
    this_mask = (f_in == v_num_new(v_idx));
    f_out(this_mask) = v_idx;
end

% remove any faces that reference vertices that are being removed
nan_mask = isnan(f_out(:,1)) | isnan(f_out(:,2)) | isnan(f_out(:,3));
f_out(nan_mask,:) = [];

% now actually remove the vertices
v_out = v_in;
v_out(v_to_remove,:) = [];