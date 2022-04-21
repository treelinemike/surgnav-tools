function calplate_data = compute_stereo_calplate_transforms(stereoParams,ckbd_tmp,sync_times, L_filenames,R_filenames,doSaveCheckerboardFigs,doMakeCheckerboardMovie)

% check length of filename lists
if( (size(L_filenames,1) ~= size(R_filenames,1)) || ( ~isempty(sync_times) && (size(sync_times,1) ~= size(L_filenames,1))) )
    error('Filename lists and sync time list must all have same length!');
end

% initialize storage
calplate_data = [];

% extract principal points for L & R images
pp_L = stereoParams.CameraParameters1.Intrinsics.PrincipalPoint;
pp_R = stereoParams.CameraParameters2.Intrinsics.PrincipalPoint;

% initialize figure
fh = figure;
set(gcf,'Position',[1.698000e+02 1.722000e+02 1.199200e+03 0460]);
fh.Color = [0 0 0];

% iterate through each stereo pair in the experiment
for test_idx = 1:size(L_filenames,1)

    % show sync time
    if(~isempty(sync_times))
        sync_time_string = sync_times{test_idx};
        sync_time_sec =  time_str_to_sec(sync_time_string);
        % fprintf('Stereo pair sync time (sec): %d\n',uint64(sync_time_sec));
    else
        sync_time_string = '??:??:??';
    end

    % load a stereo pair
    % TODO: we can't reliably detect the checkerboard in the rectified images,
    % so we'll just have to pick one (or maybe a few?) that work to use going
    % forward
    im_L_filename = L_filenames{test_idx};
    im_L = imread(im_L_filename);
    im_R_filename = R_filenames{test_idx};
    im_R = imread(im_R_filename);

    % encode principal point in a grayscale image
    im_aug_L = encode_principalpoint(pp_L(1),pp_L(2),size(im_L,2),size(im_L,1),255);
    im_aug_R = encode_principalpoint(pp_R(1),pp_R(2),size(im_R,2),size(im_R,1),255);

    % rectify stereo pairs
    % MATLAB documentation recommends setting 'OutputView' to 'Valid' ("most suitable for computing disparity")
    [rect_L,rect_R] = rectifyStereoImages(im_L,im_R,stereoParams,'OutputView','valid','FillValues',65535*ones(3,1));  % OutputView if 'full' or 'valid'
    [rect_aug_L,rect_aug_R] = rectifyStereoImages(im_aug_L,im_aug_R,stereoParams,'OutputView','valid','FillValues',255);  % OutputView if 'full' or 'valid'

    % find the tracer pixels in the rectified/undistorted stereo pair
    % identifies the location of the prinicpal point in the "undistorted" image
    % ideally this should have the same coordinates in L and R image after rectification
    pp_rect_L = decode_principalpoint(rect_aug_L);
    pp_rect_R = decode_principalpoint(rect_aug_R);

    % threshold rectified images adaptively to product binary masks
    % this facilitates checkerboard detection
    rect_L = uint8(imbinarize(rgb2gray(rect_L),'adaptive')*255);
    rect_R = uint8(imbinarize(rgb2gray(rect_R),'adaptive')*255);

    % % display red/cyan anaglyph
    % im_anaglyph = stereoAnaglyph(rect_L,rect_R);
    % imtool(im_anaglyph);  % use imtool to measure disparity manually at various points, compare to ckbd_tmp(:,3)

    % display left and right images
    % raw on top
    % rectified below
    % show principal point (projection of optical center) in each image
    t = tiledlayout(2,3);
    t.Padding = 'tight';
    t.TileSpacing = 'tight';
    nexttile(1);
    imshow(im_L);
    hold on; axis image;
    plot(pp_L(1),pp_L(2),'+','MarkerSize',20,'LineWidth',2.5,'Color',[0 0.8 0.8]);
    text(10,720,0,{im_L_filename,sync_time_string},'Color',[0 1 0],'FontSize',10,'VerticalAlignment','cap','Rotation',90,'FontName','FixedWidth','FontWeight','bold');
    nexttile(2);
    imshow(im_R);
    hold on; axis image;
    plot(pp_R(1),pp_R(2),'+','MarkerSize',20,'LineWidth',2.5,'Color',[0 0.8 0.8]);
    text(10,720,0,{im_L_filename,sync_time_string},'Color',[0 1 0],'FontSize',10,'VerticalAlignment','cap','Rotation',90,'FontName','FixedWidth','FontWeight','bold');
    nexttile(4);
    imshow(rect_L);
    hold on; axis image;
    plot(pp_rect_L(1),pp_rect_L(2),'+','MarkerSize',20,'LineWidth',2.5,'Color',[0 0.8 0.8]);
    nexttile(5);
    imshow(rect_R);
    hold on; axis image;
    plot(pp_rect_R(1),pp_rect_R(2),'+','MarkerSize',20,'LineWidth',2.5,'Color',[0 0.8 0.8]);

    % find checkerboard in L and R RECTIFIED images
    % TODO: MAGIC NUMBERS!
    [ckbd,borSize,pairsUsed] = detectCheckerboardPoints(rect_L,rect_R);
    if( (borSize(1) ~= 7) || (borSize(2) ~= 10))
        [ckbd,borSize,pairsUsed] = detectCheckerboardPoints(rect_L,rect_R,'MinCornerMetric',0.4);
    end
    if( (borSize(1) ~= 7) || (borSize(2) ~= 10))
        [ckbd,borSize,pairsUsed] = detectCheckerboardPoints(rect_L,rect_R,'MinCornerMetric',0.2);
    end
    if( (borSize(1) ~= 7) || (borSize(2) ~= 10))
        error('Cannot resolve checkerboard!');
    end
    ckbd = squeeze(ckbd);
    ckbd_L = ckbd(:,:,1);
    ckbd_R = ckbd(:,:,2);

    % overlay checkerboards on the rectified images
    nexttile(4);
    plot(ckbd_L(:,1),ckbd_L(:,2),'.','MarkerSize',20,'Color',[1 0.5 0]);
    plot(ckbd_L(1,1),ckbd_L(1,2),'o','MarkerSize',10,'LineWidth',2.5,'Color',[1 0.5 0]);
    nexttile(5);
    plot(ckbd_R(:,1),ckbd_R(:,2),'.','MarkerSize',20,'Color',[1 0.5 0]);
    plot(ckbd_R(1,1),ckbd_R(1,2),'o','MarkerSize',10,'LineWidth',2.5,'Color',[1 0.5 0]);

    % make sure checkerboards are the same size
    assert(prod(size(ckbd_L) == size(ckbd_R)),'Checkerboards are not the same size!');

    % RECONSTRUCT CHECKERBOARD
    % i.e. compute the 3D position of each point in the checkerboard
    % w.r.t. some frame... we'll call it the "recon" frame
    % which should be situated generally near the endoscope tip

    % initialize disparity map and lookup table
    dmap = nan(size(rect_L,1),size(rect_L,2));
    pointLUT = nan(size(ckbd_L,1),3);

    % add each checkerboard point to the disparity map
    for pointIdx = 1:size(ckbd_L,1)
        col = round(ckbd_L(pointIdx,1));
        col_error = ckbd_L(pointIdx,1)-ckbd_R(pointIdx,1); % this is disparity!
        %     col_error = (ckbd_L(pointIdx,1)-pp_rect_L(1))-(ckbd_R(pointIdx,1)-pp_rect_R(1)); % this is disparity, computed relative to tracked principal point...
        row = round(ckbd_L(pointIdx,2));
        row_error = ckbd_L(pointIdx,2)-ckbd_R(pointIdx,2); % this is just a check, ideally zero for rectified images
        dmap(row,col) = col_error;
        pointLUT(pointIdx,:) = [row,col,col_error];
    end

    % compute 3D positions
    points3D = reconstructScene(dmap, stereoParams);  % TODO: dive deeper into geometry here, for now using black box function

    % extract points out of point cloud in proper order
    points_3D_vecs = nan(size(ckbd_L,1),3);
    for pointIdx = 1:size(ckbd_L,1)
        points_3D_vecs(pointIdx,:) = points3D( pointLUT(pointIdx,1), pointLUT(pointIdx,2), :);
    end

    % align template with reconstructed point cloud
    [ckbd_tmp_aligned,TF_calplate_to_recon,ckbd_stereo_to_template_rmse] = rigid_align_svd(ckbd_tmp',points_3D_vecs');
    ckbd_tmp_aligned = ckbd_tmp_aligned';

    % store data
    calplate_data(test_idx).TF_calplate_to_recon = TF_calplate_to_recon;
    calplate_data(test_idx).calplate_dots_in_recon_frame = points_3D_vecs;

    % display checkerboard point sets in 3D
    p1 = TF_calplate_to_recon(1:3,4);
    ah = nexttile(3,[2,1]);
    hold on; grid on;
    plot3(points_3D_vecs(:,1),points_3D_vecs(:,2),points_3D_vecs(:,3),'.','MarkerSize',20,'Color',[0 0 0.8]);
    plot3(ckbd_tmp_aligned(:,1),ckbd_tmp_aligned(:,2),ckbd_tmp_aligned(:,3),'o','MarkerSize',5,'LineWidth',2,'Color',[0.8 0 0]);
    plotTriad(TF_calplate_to_recon,8);
    plot3(0,0,0,'.','MarkerSize',50,'Color',0.5*ones(1,3)); % camera
    xlabel('\bfx');
    ylabel('\bfy');
    zlabel('\bfz');
    view([0,-90]);
    axis equal;
    ah.XAxis.Color = [1 1 1];
    ah.YAxis.Color = [1 1 1];
    ah.ZAxis.Color = [1 1 1];
    ah.Color = 0.15*ones(1,3);
    title(sprintf('Template Fit %0.4fmm RMSE',ckbd_stereo_to_template_rmse),'FontName','fixedwidth','FontSize',10,'FontWeight','bold','Color',[0 1 0]);
    xlim([-50 50]);
    ylim([-50 50]);
    zlim([-5 120]);
    drawnow;

    % save figure as image file if desired
    if(doSaveCheckerboardFigs)
        thisImgFile = sprintf('ckbd%03d.png',test_idx);
        exportgraphics(gcf,thisImgFile,'BackgroundColor',[ 0 0 0])
        system(['convert -trim ' thisImgFile ' ' thisImgFile]);  % REQUIRES convert FROM IMAGEMAGICK!
    end

end

% generate video if desired
if(doSaveCheckerboardFigs && doMakeCheckerboardMovie)
    system('ffmpeg -y -r 2 -start_number 1 -i ckbd%03d.png -vf scale="trunc(iw/2)*2:trunc(ih/2)*2" -c:v libx264 -profile:v high -pix_fmt yuv420p -g 25 -r 25 ckbd.mp4');
end