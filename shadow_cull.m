% backface culling based on shadow casting
%
% given a surface mesh and a camera orientation
% remove all faces that cannot be seen by a pinhole camera
% with lens oriented along camera z axis
%
% first we remove any faces for which we would be looking at the backside
% then we sort faces in order of increasing distance from the camera
% and work down the list casting a shadow from the camera to each face and
% removing any other faces that have a vertex in the shadow
%
% this isn't perfect (e.g. a face could project a shadow that goes clear
% through another face without including any of its vertices and fail to
% exclude it) but it is simple and works reasonably well... there are
% better ray-tracing renderers/shaders that could do this more efficiently
%
function [f_shadow,v_shadow] = shadow_cull(tri_input,TF_camera,plot_flag)

% assume we are not plotting unless explicitly specified
if(nargin < 3)
    plot_flag = false;
end

% figure handles
fha = 3423;
fhb = 1231;

% extract camera origin from camera TF passed in
% TF is assumed from origin & std. basis of space of mesh vertex coords
cam_loc = TF_camera(1:3,4);

% first reject any faces that we would be seeing from the back side
f_norms = faceNormal(tri_input);
face_mask = false(size(f_norms,1),1);
cam_vec = TF_camera(1:3,3);
for face_idx = 1:size(f_norms)
    this_face_normal = f_norms(face_idx,:)';
    if(dot(this_face_normal,cam_vec) < -0.1)
        face_mask(face_idx) = true;
    end
end
v_culled = tri_input.Points;
f_culled = tri_input.ConnectivityList(face_mask,:);
[f_culled, v_culled] = makmesh_removeUnusedVertices(f_culled,v_culled);
f_culled = makmesh_trimIslands(f_culled,v_culled);
[f_culled, v_culled] = makmesh_removeUnusedVertices(f_culled,v_culled);

% display result of initial normal-based culling
if(plot_flag)
    figure(fha);
    hold on; grid on; axis equal;
    patch('vertices',v_culled,'faces',f_culled,'FaceColor',[0.6 1 1],'EdgeColor',[0 0 0],'FaceAlpha',0.5);
    plotTriad(TF_camera,10);
end

% make sure we haven't eliminated the entire mesh!
if( isempty(f_culled) )
    error('No faces remain in triangulation! Cannot cull.');
end

% use "shadow casting" to eliminate all occluded surface patches,
% cast shadows from each triangle, eliminating all triangles that have
% at least vertex in the shadow

% sort faces by distance between triangle centroid and camera
[~,sortedFaceInds] = sort(vecnorm(incenter(triangulation(f_culled,v_culled))-cam_loc',2,2));

% examine vertices in order of increasing distance from camera
faceOrderIdx = 1;
while( faceOrderIdx <= length(sortedFaceInds) )

    % get index of face in currentObsFaces
    faceIdx = sortedFaceInds(faceOrderIdx);

    % compute normals to pyramidal faces of shadow, ensuring
    % that they point INWARD!
    abcVecs = v_culled(f_culled(faceIdx,:),:) - cam_loc';
    n1 = unitvec(cross(abcVecs(1,:),abcVecs(2,:)));
    n1 = n1*sign(dot(n1,abcVecs(3,:)));
    n2 = unitvec(cross(abcVecs(1,:),abcVecs(3,:)));
    n2 = n2*sign(dot(n2,abcVecs(2,:)));
    n3 = unitvec(cross(abcVecs(2,:),abcVecs(3,:)));
    n3 = n3*sign(dot(n3,abcVecs(1,:)));

    % assemble into shadow volume
    shadowVol.norms = [n1; n2; n3];
    shadowVol.normPoints = repmat(cam_loc',3,1);

    facesToRemoveMask = getObsFaces(v_culled,f_culled(sortedFaceInds,:),shadowVol,1);
    facesToRemoveMask(1:faceOrderIdx) = 0;

    % show this step
    if(plot_flag)
        figure(fhb)
        cla
        hold on; grid on; axis equal;
        view([10,-60]);
        acceptedFaces = f_culled(sortedFaceInds(1:faceOrderIdx),:);
        allFacesInPlay = f_culled(sortedFaceInds(faceOrderIdx:end),:);
        currentShadowFace = f_culled(faceIdx,:);
        currentFacesToRemove = f_culled(sortedFaceInds(facesToRemoveMask),:);
        patch('Faces',acceptedFaces,'Vertices',v_culled,'FaceColor',[0.5 0.5 0.5],'EdgeColor','k','LineWidth',0.01);
        patch('Faces',allFacesInPlay,'Vertices',v_culled,'FaceColor',[0.8 0.8 0.8],'EdgeColor','k','LineWidth',0.01);
        patch('Faces',currentShadowFace,'Vertices',v_culled,'FaceColor',[0 0.8 0],'EdgeColor','k','LineWidth',0.01);
        patch('Faces',currentFacesToRemove,'Vertices',v_culled,'FaceColor',[1 .50 .50],'EdgeColor','k','LineWidth',0.01);
        plotTriad(TF_camera,10);

        % generate and plot shadow volume
        shadowFaces = [
            1 3 4 2 1;
            3 5 6 4 3;
            5 1 2 6 5;
            2 4 6 2 NaN ];
        shadowVertices = zeros(6,3);

        % find end face distance along camera z direction
        R = TF_camera(1:3,1:3);
        t = TF_camera(1:3,4);
        v_culled_cam = ((R')*(v_culled'-t))';
        z_max_cam = max(v_culled_cam(:,3));

        for ii = 1:3
            % how far along point unit vector do we need to extend shadow?
            c = 1.2*((z_max_cam)/dot(TF_camera(1:3,3),abcVecs(ii,:)'));

            % draw line along unit vector just to surface patch
            plot3(cam_loc(1)+[0 abcVecs(ii,1)],cam_loc(2)+[0 abcVecs(ii,2)], cam_loc(3)+[0 abcVecs(ii,3)],'k-','LineWidth',1.6);

            % vertices at patch intersection and at shadow endpoint
            shadowVertices(2*ii-1,:) = cam_loc'+abcVecs(ii,:);
            shadowVertices(2*ii,:) = cam_loc'+c*abcVecs(ii,:);
        end

        % plot shadow volume
        patch('Faces',shadowFaces,'Vertices',shadowVertices,'FaceColor',[.6 .6 .6],'EdgeColor','k','EdgeAlpha',1,'FaceVertexAlphaData',0.2,'FaceAlpha','flat','LineWidth',2);
    end

    % actually remove the faces
    sortedFaceInds(facesToRemoveMask) = [];

    % move to next face
    faceOrderIdx = faceOrderIdx + 1;

end
f_shadow = f_culled(sortedFaceInds,:);
v_shadow = v_culled;
[f_shadow,v_shadow] = makmesh_removeUnusedVertices(f_shadow,v_shadow);
f_shadow = makmesh_trimIslands(f_shadow,v_shadow);

% show
if(plot_flag)
    figure(fha);
    patch('vertices',v_shadow,'faces',f_shadow,'FaceColor',[0.6 1 0.6],'EdgeColor',[0 0 0],'FaceAlpha',0.5);
end

end

% find points inside a volume defined by a series of intersecting planes
% vol structure includes both INWARD POINTING normals as well as a point in
% each plane to serve as origin for evaluating which side of the plane
% query vertices are on
function pointMask = findPointsInVol(allPoints,vol)
pointMask = ones(size(allPoints,1),1);
numPlanes = size(vol.norms,1);
for planeIdx = 1:numPlanes
    thisNorm = vol.norms(planeIdx,:);
    thisPoint = vol.normPoints(planeIdx,:);
    pointMask = pointMask & ((allPoints-thisPoint)*thisNorm' > (1e-6));  % not just > 0 because don't want to throw out vertices of points in the current patch
end
end

% generate list of faces whose vertices are fully or partially contained within volume
% the includePartials flag indicates whether to include faces with some but
% not all vertices contained in the volume
function [obsFaceMask,obsVertexMask] = getObsFaces(vertices,faces,vol,includePartials)

% determine which verties are within volume
obsVertexMask = findPointsInVol(vertices,vol);

% determine which faces use these vertices
[tf,~] = ismember(faces,find(obsVertexMask));
if(includePartials)
    obsFaceMask = (sum(tf,2) > 0);
else
    obsFaceMask = (prod(tf,2) > 0);
end
end
