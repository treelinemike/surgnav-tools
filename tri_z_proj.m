% function proj_poly = tri_z_proj(tri)
close all; clear; clc;
tri = stlread('C:\Users\f002r5k\GitHub\matlab-examples\candycane.stl');
v_tris = vertexAttachments(tri);

rng(1233);  % 1231
R = tang2matrix(randRotUnifAng_t([0,0,0]',pi,1))

% merge duplicate vertices
proj_pts = tri.Points*R';
proj_pts = proj_pts(:,1:2);
proj_pts_unique = unique(proj_pts,'rows');
[~,vertex_map] = ismember(proj_pts,proj_pts_unique,'rows'); 
proj_cl = [vertex_map(tri.ConnectivityList(:,1)) vertex_map(tri.ConnectivityList(:,2)) vertex_map(tri.ConnectivityList(:,3))];
proj_tri = triangulation(proj_cl,proj_pts_unique);

figure;
hold on; grid on; axis equal;
patch('Faces',proj_tri.ConnectivityList,'Vertices',proj_tri.Points,'FaceColor',[0.3 0.3 0.3],'EdgeColor',[0.3 0.3 0.3],'LineWidth',0.5);
patch('Faces',proj_tri.ConnectivityList,'Vertices',proj_tri.Points,'FaceColor','none','EdgeColor',[0 0 0],'LineWidth',0.5);
plot( proj_tri.Points(:,1), proj_tri.Points(:,2), 'r.', 'MarkerSize', 10 );

% starting point, closest to lower right corner
pts = proj_pts_unique;
% pt_lr = [min(pts(:,1)) min(pts(:,2))];
% [~,this_node_idx] = min(vecnorm(pts-pt_lr,2,2));
[~,this_node_idx] = min(pts(:,2));
plot( pts(this_node_idx,1), pts(this_node_idx,2), 'm*', 'MarkerSize',40,'LineWidth',2 );

% plot( pts(this_node_idx,1), pts(this_node_idx,2), 'go', 'MarkerSize',4,'LineWidth',2 );
attached_tri_idx = vertexAttachments(proj_tri,this_node_idx);
attached_tri_idx = attached_tri_idx{1};
neighbor_nodes = [];
for i = 1:length(attached_tri_idx) % look at each triangle that uses this node
   this_tri_idx = attached_tri_idx(i);
   this_tri_nodes = proj_tri.ConnectivityList(this_tri_idx,:);
   for j = 1:length(this_tri_nodes)  % look at every node of the attached triangle
      if( this_tri_nodes(j) ~= this_node_idx )
          neighbor_nodes(end+1) = this_tri_nodes(j);
      end
   end
end

% Because we know we are at a lower y bound the maximum angle will be
% <= 180deg
angle_data = nan( nchoosek( length(neighbor_nodes), 2 ),4);
angle_idx = 1;
pt_this_node = pts(this_node_idx,:);
for i = 1:length(neighbor_nodes)
    for j = (i+1):length(neighbor_nodes)
        v1 = pts(neighbor_nodes(i),:) - pt_this_node;
        v2 = pts(neighbor_nodes(j),:) - pt_this_node;
        this_angle = acos( dot(v1,v2) / (norm(v1)*norm(v2)) ); 
        angle_data(angle_idx,:) = [neighbor_nodes(i), neighbor_nodes(j), this_angle, norm(v1)+norm(v2)];
        angle_idx = angle_idx + 1;
    end
end
angle_data = sortrows(angle_data,[3,4],'descend');


% now we know the other two vertices attached to our current vertex in the
% final outline, but we need to get them in the correct order
neighbor_node_idx = angle_data(1,1:2);
[~,sortMask] = sortrows(pts(neighbor_node_idx,:),1,'ascend');
neighbor_nodes_final = neighbor_node_idx(sortMask)
final_vertex_list = [ neighbor_nodes_final(1), this_node_idx, neighbor_nodes_final(2)];

% show first step
plot( pts(final_vertex_list(1),1), pts(final_vertex_list(1),2), 'ro', 'MarkerSize',4,'LineWidth',2 );
plot( pts(final_vertex_list(2),1), pts(final_vertex_list(2),2), 'go', 'MarkerSize',4,'LineWidth',2 );
plot( pts(final_vertex_list(3),1), pts(final_vertex_list(3),2), 'bo', 'MarkerSize',4,'LineWidth',2 );

% now do every other step....
while( final_vertex_list(end) ~= final_vertex_list(1))
    
end

% end