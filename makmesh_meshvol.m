% calculate volume enclosed by mesh using the divergence theorem
% TODO: should first check mesh to ensure it is a single closed volume
function vol = makmesh_meshvol(thisMesh)
    faceList = thisMesh.ConnectivityList;
    if(size(faceList,2) ~= 3)
        error('Mesh faces are not triangular!');
    end
    
    % analysis point is centroid per derivation via divergence theorem,
    % but we can use ANY POINT IN THE PLANE OF THE TRIANGLE because the
    % error introduced is perpendicular to the face normal, and thus does
    % not contribute to the dot product... thus, just use the first vertex
    % of each triangle as the analysis point
    firstVertices = thisMesh.Points(faceList(:,1),:);
    %centroids = barycentricToCartesian(thisMesh,(1:size(faceList,1))',(1/3)*ones(size(faceList,1),3));
    %incenters = thisMesh.incenter;
    analysisPoints = firstVertices;
        
    % compute area of each triangle
    areas = makmesh_triarea(thisMesh);
    
    % compute face normal for each triangle
    faceNormals = thisMesh.faceNormal;
    
    % compute volume via the divergence theorem
    vol = 0;
    for i = 1:size(faceList,1)
%         fprintf('%8.4f vs %8.4f vs %8.4f\n', ...
%             dot(centroids(i,:)',faceNormals(i,:)'), ...
%             dot(incenters(i,:)',faceNormals(i,:)'), ...
%             dot(firstpoints(i,:)',faceNormals(i,:)'));
        vol = vol + (1/3)*dot(analysisPoints(i,:)',faceNormals(i,:)')*areas(i);
    end
end