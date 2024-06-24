function pc_out = stereoPCDistanceFilter(pc_in,threshold_ratio,varargin) 
    
    % determine whether we should show plots
    show_plots = false;
    if(nargin > 2)
        show_plots = logical(varargin{1});
    end
    if(show_plots)
        figure;
        subplot(6,2,1:4);
        cla;
        hold on; grid on;
    end

    % apply point cloud filtering
    x = reshape(pc_in.Location(:,:,1),[],1);
    y = reshape(pc_in.Location(:,:,2),[],1);
    z = reshape(pc_in.Location(:,:,3),[],1);
    infmask = isinf(x) | isinf(y) | isinf(z);
    allpts = [x(~infmask) y(~infmask) z(~infmask)];
    allcolors = [ reshape(pc_in.Color(:,:,1),[],1) reshape(pc_in.Color(:,:,2),[],1) reshape(pc_in.Color(:,:,3),[],1)];
    allcolors = allcolors(~infmask,:);
    dists = vecnorm(allpts,2,2);
    raw_dists = dists;
    dmu = mean(raw_dists,'omitnan');
    dsig = std(raw_dists,'omitnan');
    outlier_mask = (raw_dists < (dmu-4*dsig)) | (raw_dists > (dmu + 4*dsig));
    raw_dists(outlier_mask) = NaN;

    [pdf_f,pdf_xi] = ksdensity(raw_dists,'Function','pdf','NumPoints',400); % TODO: this is pretty slow!

    pdf_threshold = threshold_ratio*max(pdf_f);
    pdf_high_mask = pdf_f > pdf_threshold;
    pdf_transitions = [0 diff(pdf_high_mask)];
    pdf_transition_up_list = find(pdf_transitions == 1);
    pdf_transition_down_list = find(pdf_transitions == -1);
    savemask = false(size(raw_dists));
    for cluster_idx = 1:length(pdf_transition_up_list)
        xi_start = pdf_xi(pdf_transition_up_list(cluster_idx));
        xi_end = pdf_xi(find( (pdf_xi > xi_start) & (pdf_transitions == -1) ,1,'first'));
        savemask = savemask | ((raw_dists >= xi_start) & (raw_dists <= xi_end));
    end
    final_dists = raw_dists(savemask);
    reject_dists = raw_dists(~savemask);
    
    % show PDF thresholding
    if(show_plots)
        plot(pdf_xi,pdf_f,'LineWidth',1.6,'Color',[0 0 0.8]);
        plot(final_dists,zeros(1,length(final_dists)),'.','MarkerSize',6,'Color',[0 0.8 0]);
        plot(reject_dists,zeros(1,length(reject_dists)),'.','MarkerSize',6,'Color',[0.8 0 0]);
        plot(xlim,pdf_threshold*ones(2,1),'-','Color',[0.8 0 0]);
        ylim([0 max(pdf_f);]);
    end

    % generate and show point cloud with clipping highlighted
    if(show_plots)
        filtcolors = allcolors;
        filtcolors(~savemask,:) = repmat([204 0 0],nnz(~savemask),1);
        pc1 = pointCloud(allpts,"Color",filtcolors);
        subplot(6,2,[7 9 11]);
        pcax(1) = pcshow(pc1, 'VerticalAxis', 'z', 'VerticalAxisDir', 'down','BackgroundColor',[1 1 1]);
        axis equal
    end

    % generate and show final filtered point cloud
    allpts = allpts(savemask,:);
    allcolors = allcolors(savemask,:);
    pc_out = pointCloud(allpts,"Color",allcolors);
    if(show_plots)
        subplot(6,2,[8 10 12]);
        pcax(2) = pcshow(pc_out, 'VerticalAxis', 'z', 'VerticalAxisDir', 'down','BackgroundColor',[1 1 1]);
        axis equal
        % link axes
        pclink = linkprop(pcax,{'CameraUpVector','CameraPosition'});
        setappdata(gcf, 'StoreTheLink', pclink);
    end
end