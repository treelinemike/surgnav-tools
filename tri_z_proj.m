% crude projection of a triangulation onto the xy plane (remove z coordinate) and
% compute bounding polygon... doesn't capture any holes in triangulation!
%
% h = spatial sampling length

function proj_poly = tri_z_proj(tri,h,reduction_factor)

% merge duplicate vertices
proj_pts = tri.Points(:,1:2);
proj_pts_unique = unique(proj_pts,'rows');
[~,vertex_map] = ismember(proj_pts,proj_pts_unique,'rows');
proj_cl = [vertex_map(tri.ConnectivityList(:,1)) vertex_map(tri.ConnectivityList(:,2)) vertex_map(tri.ConnectivityList(:,3))];

if(nargin > 2)
    [proj_cl,proj_pts_unique] = reducepatch(proj_cl,proj_pts_unique,reduction_factor);
    proj_pts_unique = proj_pts_unique(:,1:2);
end
% sample space
samp_x_vals = min(proj_pts_unique(:,1)):h:max(proj_pts_unique(:,1));
samp_y_vals = min(proj_pts_unique(:,2)):h:max(proj_pts_unique(:,2));
[XX,YY] = meshgrid(samp_x_vals,samp_y_vals);
qp = [XX(:),YY(:)];
qp_bkgnd_mask = ones(size(qp,1),1);

% step through every face in body
for tri_idx = 1:size(proj_cl,1)
   tri_vert_idx = proj_cl(tri_idx,[1:end]);
   qp_mask_local = ones(size(qp_bkgnd_mask,1),1);
   
   % step through each vertex in face
   for i = 1:3
       % compute normal vector to edge
       ptidx0 = tri_vert_idx(mod(i-1,3)+1);
       ptidx1 = tri_vert_idx(mod(i,3)+1);
       ptidx2 = tri_vert_idx(mod(i+1,3)+1);
       pt0 = proj_pts_unique(ptidx0,:);
       pt1 = proj_pts_unique(ptidx1,:);
       pt2 = proj_pts_unique(ptidx2,:);
       v= pt1-pt0;
       nrm10 = [-v(2) v(1)];
       nrm10 = nrm10/norm(nrm10);
       
       % adjust normal vector sign if triangle is given CW instead of CCW
       v2 = pt2-pt0;
       if( dot(v2,nrm10) < 0)
           nrm10 = -1*nrm10;
       end
       
       % find points that are inside the triangle
       this_qp_mask = (qp-pt0)*nrm10';
       qp_mask_local = qp_mask_local & (this_qp_mask > 0);
   end 
   qp_bkgnd_mask = qp_bkgnd_mask & (~qp_mask_local);
end

% compute boudary
qp_interior = qp(~qp_bkgnd_mask,:);
qp_bnd_idx = boundary(qp_interior,1);
qp_bnd = qp_interior(qp_bnd_idx,:);

% construct shadow polygon
proj_poly = polyshape( qp_bnd(:,1), qp_bnd(:,2),'Simplify',false);

end
