% find checkerboard intersections in undistorted L/R images
% then find transform for pose of template such that intersections
% project to the L/R image planes with minimal overall RMSE

function transform_data = compute_stereo_calplate_transforms_v3(stereoParams,ckbd_tmp,sync_times, L_filenames,R_filenames,options)

arguments
    stereoParams
    ckbd_tmp double
    sync_times cell
    L_filenames cell
    R_filenames cell
    options.doSaveCheckerboardFigs = false
    options.doMakeCheckerboardMovie = false
    options.dynamic_transform_data = []
    options.RMSE_MAX = 4;
end

% check length of filename lists
if( (size(L_filenames,1) ~= size(R_filenames,1)) || ( ~isempty(sync_times) && (size(sync_times,1) ~= size(L_filenames,1))) )
    error('Filename lists and sync time list must all have same length!');
end

% load any transform data provided
transform_data = [];
if(~isempty(options.dynamic_transform_data) )
    transform_data = options.dynamic_transform_data;
end

% load max rmse
RMSE_MAX = options.RMSE_MAX;
fprintf('RMSE Max set to %0.2f pixels\n',RMSE_MAX);

% extract principal points for L & R images
pp_L = stereoParams.CameraParameters1.Intrinsics.PrincipalPoint;
pp_R = stereoParams.CameraParameters2.Intrinsics.PrincipalPoint;

% initialize figure
figid_main = 9876;
fh = figure(figid_main);
set(gcf,'Position',[0184 0329 0804 0460]);
fh.Color = [0 0 0];

% iterate through each stereo pair in the experiment
for pose_idx = 1:size(L_filenames,1)

    % show sync time
    if(~isempty(sync_times))
        sync_time_string = sync_times{pose_idx};
        sync_time_sec =  time_str_to_sec(sync_time_string);
        % fprintf('Stereo pair sync time (sec): %d\n',uint64(sync_time_sec));
    else
        sync_time_string = '??:??:??';
    end

    % load a stereo pair
    im_L_filename = L_filenames{pose_idx};
    im_L = imread(im_L_filename);
    im_R_filename = R_filenames{pose_idx};
    im_R = imread(im_R_filename);

    % display filename
    fprintf('Loading file: %s\n',im_L_filename);

    % TODO: UNDISTORT HERE, ESPECIALLY FOR DA VINCI S
    im_L_undistort = undistortImage(im_L,stereoParams.CameraParameters1,"cubic",'OutputView','same');
    im_R_undistort = undistortImage(im_R,stereoParams.CameraParameters2,"cubic",'OutputView','same');


    % display left and right images
    % raw on top
    % undistorted below
    figure(figid_main);
    t = tiledlayout(2,2);
    t.Padding = 'tight';
    t.TileSpacing = 'tight';
    nexttile(1);
    imshowpair(im_L,im_L_undistort);
    hold on; axis image;
    text(10,720,0,{im_L_filename,sync_time_string},'Color',[0 1 0],'FontSize',10,'VerticalAlignment','cap','Rotation',90,'FontName','FixedWidth','FontWeight','bold');
    nexttile(2);
    imshowpair(im_R,im_R_undistort);
    hold on; axis image;
    text(10,720,0,{im_R_filename,sync_time_string},'Color',[0 1 0],'FontSize',10,'VerticalAlignment','cap','Rotation',90,'FontName','FixedWidth','FontWeight','bold');
    nexttile(3);
    imshow(im_L_undistort);
    hold on; axis image;
    nexttile(4);
    imshow(im_R_undistort);
    hold on; axis image;
    
    % find checkerboard in L and R *UNDISTORTED* images
    % TODO: MAGIC NUMBERS!
    numRows = 7;
    numCols = 10;
    [ckbd,borSize,pairsUsed] = detectCheckerboardPoints(im_L_undistort,im_R_undistort);
    if( (borSize(1) ~= numRows) || (borSize(2) ~= numCols))
        fprintf('INITIAL DETECTION FAILED!\n');
        fprintf('Trying detection with 0.4\n');
        [ckbd,borSize,pairsUsed] = detectCheckerboardPointsModified(im_L_undistort,im_R_undistort,'MinCornerMetric',0.4);
        fprintf('Found %d points\n',max((borSize(1)-1),0)*max((borSize(2)-1),0));
    end
    if( (borSize(1) ~= numRows) || (borSize(2) ~= numCols))
        fprintf('Trying detection with 0.2\n');
        [ckbd,borSize,pairsUsed] = detectCheckerboardPointsModified(im_L_undistort,im_R_undistort,'MinCornerMetric',0.2);
        fprintf('Found %d points\n',max((borSize(1)-1),0)*max((borSize(2)-1),0));
    end
    if( (borSize(1) ~= numRows) || (borSize(2) ~= numCols))
        fprintf('Trying detection with 0.1\n');
        [ckbd,borSize,pairsUsed] = detectCheckerboardPointsModified(im_L_undistort,im_R_undistort,'MinCornerMetric',0.1);
        fprintf('Found %d points\n',max((borSize(1)-1),0)*max((borSize(2)-1),0));
    end
    if( (borSize(1) ~= numRows) || (borSize(2) ~= numCols))
        warning('Cannot resolve checkerboard!');
    end
    ckbd = squeeze(ckbd);
    ckbd_pts_raw_L = ckbd(:,:,1);
    ckbd_pts_raw_R = ckbd(:,:,2);

    % overlay detected checkerboards on the undistorted images
    nexttile(3);
    plot(ckbd_pts_raw_L(:,1),ckbd_pts_raw_L(:,2),'.','MarkerSize',20,'Color',[1 0.5 0]);
    plot(ckbd_pts_raw_L(1,1),ckbd_pts_raw_L(1,2),'o','MarkerSize',10,'LineWidth',2.5,'Color',[1 0.5 0]);
    nexttile(4);
    plot(ckbd_pts_raw_R(:,1),ckbd_pts_raw_R(:,2),'.','MarkerSize',20,'Color',[1 0.5 0]);
    plot(ckbd_pts_raw_R(1,1),ckbd_pts_raw_R(1,2),'o','MarkerSize',10,'LineWidth',2.5,'Color',[1 0.5 0]);
    drawnow;

    % make sure checkerboards are the same size
    assert(prod(size(ckbd_pts_raw_L) == size(ckbd_pts_raw_R)),'Checkerboards are not the same size!');

    % try to find a good starting orientation
    detected_uv = unitvec([ckbd_pts_raw_L(1,:)-ckbd_pts_raw_L(49,:) 0]');
    x_uv = [1 0 0]';
    theta_detected = acos(dot(x_uv,detected_uv)/(norm(detected_uv)*norm(x_uv)));

    
    rmse = inf;
    loopcount = 1;
    dev = zeros(6,1);

    while(rmse > RMSE_MAX && loopcount < 20)
        fprintf('Alignment attempt #%d\n',loopcount);
        R = eye(3);
        R = R*[cos(pi/2-0.01) -sin(pi/2-0.01) 0; sin(pi/2-0.01) cos(pi/2-0.01) 0; 0 0 1];
        R = R*[cos(theta_detected) -sin(theta_detected) 0; sin(theta_detected) cos(theta_detected) 0; 0 0 1];
        R = R*[1 0 0; 0 cos(pi-0.01) sin(pi-0.01); 0 -sin(pi-0.01) cos(pi-0.01)];

        TF0_R = eye(4);
        TF0_R(1:3,1:3) = R;
        TF0_T = eye(4);
        TF0_T(1:3,4) = -1*mean(ckbd_tmp,1);
        TF0 = TF0_R*TF0_T;
        ckbd_tmp_ic = hTF(ckbd_tmp',TF0,0)';

        x0 = [ 0 0 0 0 0 100]';
        x0 = x0 + dev;

        f = @(x_current)reproj_cost(x_current,ckbd_pts_raw_L,ckbd_pts_raw_R,ckbd_tmp_ic,stereoParams);
        options= optimset('MaxFunEvals',1e12,'MaxIter',1e4);
        [x_opt,rmse] = fminsearch(f,x0,options);
        rmse = rmse
        loopcount = loopcount + 1;
        dev = dev + randn(6,1).*([0.2 0.2 0.2 10 10 20]');

    end
    if(rmse > RMSE_MAX)
        error('No good initial oritntation identified!');
    end

    TF_additional = eye(4);
    TF_additional(1:3,1:3) = tang2matrix(x_opt(1:3));
    TF_additional(1:3,4) = x_opt(4:6);
    TF_calplate_to_leyetrue = TF_additional*TF0;

    ckbd_tmp_fit_leyetrue = hTF(ckbd_tmp',TF_calplate_to_leyetrue,0)';
    ckbd_proj_raw_L = world2img(ckbd_tmp_fit_leyetrue,rigidtform3d(eye(4)),stereoParams.CameraParameters1.Intrinsics,ApplyDistortion=false);
    RMSE_LEFT = directRMSE(ckbd_proj_raw_L,ckbd_pts_raw_L)
    ckbd_proj_raw_R = world2img(ckbd_tmp_fit_leyetrue,stereoParams.PoseCamera2,stereoParams.CameraParameters2.Intrinsics,ApplyDistortion=false);
    RMSE_RIGHT = directRMSE(ckbd_proj_raw_R,ckbd_pts_raw_R)

    % plot projected points
    nexttile(3);
    plot(ckbd_proj_raw_L(:,1),ckbd_proj_raw_L(:,2),'o','MarkerSize',10,'LineWidth',2,'Color',[0 1 0]);
    nexttile(4);
    plot(ckbd_proj_raw_R(:,1),ckbd_proj_raw_R(:,2),'o','MarkerSize',10,'LineWidth',2,'Color',[0 1 0]);
    drawnow;

    % store data
    transform_data(pose_idx).TF_calplate_to_leyetrue = TF_calplate_to_leyetrue;
    transform_data(pose_idx).ckbd_tmp_fit_leyetrue = ckbd_tmp_fit_leyetrue;
    transform_data(pose_idx).ckbd_proj_raw_L = ckbd_proj_raw_L;  % checkerboard TEMPLATE transformed to left eye raw space

end
end



%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% cost function for estimating T_robot_to_polaris
function rmse = reproj_cost(x,ckbd_truth_L,ckbd_truth_R,ckbd_tmp,stereoParams)


% get the current estimate of the transform from ecmtip to recon frame
TF = eye(4);
TF(1:3,1:3) = tang2matrix(x(1:3));
TF(1:3,4) = x(4:6);

% transform template points per current matrix
ckbd_tmp = hTF(ckbd_tmp',TF,0)';
ckbd_tmp_proj_L = world2img(ckbd_tmp,rigidtform3d(eye(4)),stereoParams.CameraParameters1.Intrinsics,ApplyDistortion=false);
ckbd_tmp_proj_R = world2img(ckbd_tmp,stereoParams.PoseCamera2,stereoParams.CameraParameters2.Intrinsics,ApplyDistortion=false);
    
% compute RMSE
sse = vecnorm((ckbd_tmp_proj_L - ckbd_truth_L),2,2).^2;
sse = [sse; vecnorm((ckbd_tmp_proj_R - ckbd_truth_R),2,2).^2];
rmse = sqrt(mean(sse));

end
