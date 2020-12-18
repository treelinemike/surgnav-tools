
function proj_poly = tri_z_proj(tri,h)
% close all; clear; clc;
% tri = stlread('C:\Users\f002r5k\GitHub\matlab-examples\candycane.stl');
% h = 1;
%
% % rng(4233);  % 1231
% % R = tang2matrix(randRotUnifAng_t([0,0,0]',pi,1))
% 
% 
% R = [    0.1543         0   -0.9880
%          0    1.0000         0
%     0.9880         0    0.1543];

% merge duplicate vertices
% proj_pts = tri.Points*R';
% proj_pts = proj_pts(:,1:2);
proj_pts = tri.Points(:,1:2);
proj_pts_unique = unique(proj_pts,'rows');
[~,vertex_map] = ismember(proj_pts,proj_pts_unique,'rows');
proj_cl = [vertex_map(tri.ConnectivityList(:,1)) vertex_map(tri.ConnectivityList(:,2)) vertex_map(tri.ConnectivityList(:,3))];

% sample space
% N_pts = 100; 
% samp_x_vals = linspace(min(proj_pts_unique(:,1)),max(proj_pts_unique(:,1)),N_pts)
% samp_y_vals = linspace(min(proj_pts_unique(:,2)),max(proj_pts_unique(:,2)),N_pts)
samp_x_vals = min(proj_pts_unique(:,1)):h:max(proj_pts_unique(:,1));
samp_y_vals = min(proj_pts_unique(:,2)):h:max(proj_pts_unique(:,2));
[XX,YY] = meshgrid(samp_x_vals,samp_y_vals);
qp = [XX(:),YY(:)];
qp_bkgnd_mask = ones(size(qp,1),1);

for tri_idx = 1:size(proj_cl,1)
   tri_vert_idx = proj_cl(tri_idx,[1:end]);
   qp_mask_local = ones(size(qp_bkgnd_mask,1),1);
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
%            warning('Fixing sign of normal vector');
       end
       
       % 
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

% % display stuff
% proj_tri = triangulation(proj_cl,proj_pts_unique);
% figure;
% ax = subplot(1,3,1);
% hold on; grid on; axis equal;
% pp = patch('Faces',proj_tri.ConnectivityList,'Vertices',proj_tri.Points,'FaceColor',[0.3 0.3 0.3],'EdgeColor',[0.3 0.3 0.3],'LineWidth',0.5);
% plot(qp(:,1),qp(:,2),'r.','MarkerSize',4);
% plot(qp(~qp_bkgnd_mask,1),qp(~qp_bkgnd_mask,2),'b.','MarkerSize',4);
% 
% ax(end+1) = subplot(1,3,2);
% hold on; grid on; axis equal;
% plot(qp_bnd(:,1),qp_bnd(:,2),'r-','LineWidth',2);
% 
% poly_area = area(proj_poly);
% [poly_cx poly_cy] = centroid(proj_poly);
% fprintf('Polygon area: %6.3f\n',poly_area);
% fprintf('Polygon centroid: (%6.3f,%6.3f)\n',poly_cx,poly_cy);
% 
% ax(end+1) = subplot(1,3,3);
% hold on; grid on; axis equal;
% plot(proj_poly)
% plot(poly_cx,poly_cy,'r.','MarkerSize',20);
% linkaxes(ax,'xy');