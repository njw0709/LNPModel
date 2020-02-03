function plot_sta(sta_3d_mat, rf_temporal_len, time_step)
    colormap_path = 'Visualization\RKB.mat';
    load(colormap_path);
    figure;
    levels = -1:0.1:1;
    ts_max = time_step*rf_temporal_len;
    for i = 1:rf_temporal_len
        subplot(5,ceil(rf_temporal_len/5),i);
        contourf(rescale(sta_3d_mat(:,:,i), -1, 1), levels,'LineStyle', 'none');
        colormap(color_map);
        time_delay = ts_max-(i-1)*time_step;
        title(sprintf('t = %.2fms', time_delay*1000));
    end            
end 