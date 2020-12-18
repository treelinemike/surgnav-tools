% function proj_poly = tri_z_proj(tri)
close all; clear; clc;
tri = stlread('C:\Users\f002r5k\GitHub\matlab-examples\candycane.stl');
v_tris = vertexAttachments(tri);

% rng(3127);  % 1231
% R = tang2matrix(randRotUnifAng_t([0,0,0]',pi,1))


R = [    0.1543         0   -0.9880
         0    1.0000         0
    0.9880         0    0.1543];

% merge duplicate vertices
proj_pts = tri.Points*R';
proj_pts = proj_pts(:,1:2);
% proj_pts = tri.Points(:,1:2);
proj_pts_unique = unique(proj_pts,'rows');
[~,vertex_map] = ismember(proj_pts,proj_pts_unique,'rows');
proj_cl = [vertex_map(tri.ConnectivityList(:,1)) vertex_map(tri.ConnectivityList(:,2)) vertex_map(tri.ConnectivityList(:,3))];
proj_tri = triangulation(proj_cl,proj_pts_unique);

figure;
hold on; grid on; axis equal;
pp = patch('Faces',proj_tri.ConnectivityList,'Vertices',proj_tri.Points,'FaceColor',[0.3 0.3 0.3],'EdgeColor',[0.3 0.3 0.3],'LineWidth',0.5);
patch('Faces',proj_tri.ConnectivityList,'Vertices',proj_tri.Points,'FaceColor','none','EdgeColor',[0 0 0],'LineWidth',0.5);
plot( proj_tri.Points(:,1), proj_tri.Points(:,2), 'r.', 'MarkerSize', 10 );

% try this with MESHGRID instead.... 

% nfv = reducepatch(pp)
% patch('Faces',nfv.faces,'Vertices',nfv.vertices(:,1:2),'FaceColor',[1 1 1],'EdgeColor',[0 0 0],'LineWidth',0.5);


% starting point, closest to lower right corner
pts = proj_pts_unique;
% pt_lr = [min(pts(:,1)) min(pts(:,2))];
% [~,this_node_idx] = min(vecnorm(pts-pt_lr,2,2));
[~,this_node_idx] = min(pts(:,2));
plot( pts(this_node_idx,1), pts(this_node_idx,2), 'm*', 'MarkerSize',40,'LineWidth',2 );

% plot( pts(this_node_idx,1), pts(this_node_idx,2), 'go', 'MarkerSize',4,'LineWidth',2 );
neighbor_nodes = getNeighborNodes(proj_tri,this_node_idx);

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
neighbor_nodes_final = neighbor_node_idx(sortMask);
final_vertex_list = [ neighbor_nodes_final(1), this_node_idx, neighbor_nodes_final(2)];

% show first step
plot( pts(final_vertex_list(1),1), pts(final_vertex_list(1),2), 'ro', 'MarkerSize',4,'LineWidth',2 );
plot( pts(final_vertex_list(2),1), pts(final_vertex_list(2),2), 'go', 'MarkerSize',4,'LineWidth',2 );
plot( pts(final_vertex_list(3),1), pts(final_vertex_list(3),2), 'bo', 'MarkerSize',4,'LineWidth',2 );

% now do every other step....
while( final_vertex_list(end) ~= final_vertex_list(1))
    final_vertex_list
    % get inward unit vector for previous segment
    this_node_idx = final_vertex_list(end);
    pt_0 = pts(final_vertex_list(end-1),:);
    pt_1 = pts(final_vertex_list(end),:);
    pt_10 = pt_1 - pt_0;
    prev_seg_inward_uv = [-pt_10(2) pt_10(1)];
    prev_seg_inward_uv = prev_seg_inward_uv/norm(prev_seg_inward_uv);
    plot([pt_0(1) pt_1(1)],[pt_0(2) pt_1(2)],'g-','LineWidth',2);
    plot(pt_1(1)+[0 prev_seg_inward_uv(1)], pt_1(2)+[0 prev_seg_inward_uv(2)],'m-','LineWidth',2);
    
    % examine each of the connected nodes, and jump to the one that makes the
    % largest angle
    neighbor_nodes = getNeighborNodes(proj_tri,this_node_idx);
    angle_data = [];
    for i = 1:length(neighbor_nodes)
        if( neighbor_nodes(i) ~= final_vertex_list(end-1))
            v1 = -pt_10;
            v2 = pts(neighbor_nodes(i),:)-pt_1;
            theta = acos( dot(v1,v2) / (norm(v1)*norm(v2)) );
            if( dot(v2,prev_seg_inward_uv) > 0 )
                this_angle = theta;
            else
                this_angle = 2*pi-theta;
            end
            angle_data(end+1,:) = [neighbor_nodes(i) this_angle norm(v2)];
        end
    end
    angle_data((angle_data(:,2) == 2*pi) ,:) = [];
    
    angle_data = sortrows(angle_data,[2 3],'descend');
    final_vertex_list(end+1) = angle_data(1,1);
end

% construct shadow polygon
pts_poly = pts(final_vertex_list,:);
proj_poly = polyshape( pts_poly(:,1), pts_poly(:,2),'Simplify',false);
poly_area = area(proj_poly);
[poly_cx poly_cy] = centroid(proj_poly);
fprintf('Polygon area: %6.3f\n',poly_area);
fprintf('Polygon centroid: (%6.3f,%6.3f)\n',poly_cx,poly_cy);
figure; 
subplot(1,2,1); 
hold on; grid on; axis equal; 
plot(pts_poly(:,1),pts_poly(:,2))
subplot(1,2,2);
hold on; grid on; axis equal;
plot(poly);
plot(poly_cx,poly_cy,'.','MarkerSize',30);


% end

function neighbor_nodes = getNeighborNodes(tri,node_idx)
attached_tri_idx = vertexAttachments(tri,node_idx);
attached_tri_idx = attached_tri_idx{1};
neighbor_nodes = [];
for i = 1:length(attached_tri_idx) % look at each triangle that uses this node
    this_tri_idx = attached_tri_idx(i);
    this_tri_nodes = tri.ConnectivityList(this_tri_idx,:);
    for j = 1:length(this_tri_nodes)  % look at every node of the attached triangle
        if( this_tri_nodes(j) ~= node_idx )
            neighbor_nodes(end+1) = this_tri_nodes(j);
        end
    end
end
neighbor_nodes = unique(neighbor_nodes);
end

