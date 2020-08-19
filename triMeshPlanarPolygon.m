function ConnectivityList = triMeshPlanarPolygon(N)

if(N < 3)
    error('Must have at least 3 vertices!');
end

% initialize connectivity list
ConnectivityList = [];

% start with full index list
idxList = (1:N)';

% create triangles
while( length(idxList) > 2 )
    
    if( ~mod(length(idxList),2) )
        if(idxList(end) == 1)
            idxList(end) = [];
        else
            idxList(end+1) = 1;
        end
    end
    
    endIdx = min(3,length(idxList));
    while(endIdx <=  size(idxList,1))
        if( idxList(endIdx-2) ~= idxList(endIdx))
            ConnectivityList(end+1,:) = [idxList(endIdx-2),idxList(endIdx-1),idxList(endIdx)];
        end
        endIdx = endIdx+2;
    end
    idxList = idxList(1:2:end)
end

% display result
points = nsidedpoly(N).Vertices;
tri = triangulation(ConnectivityList,points);
figure;
hold on; grid on;
patch('Faces',tri.ConnectivityList,'Vertices',points,'FaceColor','w','EdgeColor','k');
axis equal

end