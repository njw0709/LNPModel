function plot_sta(sta_3d_mat, rf_temporal_len, time_step)
    colormap_path = 'Visualization\RKB.mat';
    load(colormap_path);
    figure;
    levels = -1:0.1:1;
    ts_max = time_step*rf_temporal_len;
    sta_3d_mat = sta_3d_mat./max(max(max(abs(sta_3d_mat))));
    [x_size, y_size, ~] = size(sta_3d_mat);
    
    for i = 1:rf_temporal_len
        subplot(1,rf_temporal_len,i);
        data = zeros([x_size + 2, y_size + 2]);
        data(2 : x_size + 1, 2 : y_size + 1) = sta_3d_mat(:,:,i);
        contourf(data, levels,'LineStyle', 'none');
        colormap(color_map);
        caxis([-1 1]);
        time_delay = ts_max-(i-1)*time_step;
        title(sprintf('t = %.2fms', time_delay*1000));
        set(gca, 'XTick', [], 'YTick', [], 'YDir', 'Rev', 'DataAspectRatioMode', 'manual', ...
        'YLim', [1.5, y_size + 1.5], 'XLim', [1.5, x_size + 1.5], 'Color', 'k', 'DataAspectRatio', [1 1 1]);
        for k = 1.5 : 1 : x_size + 1.5
            line([k, k], [1.5, x_size + 1.5], 'Color', [0 0 0]);
        end
        for j = 1.5 : 1 : y_size + 1.5
            line([1.5, y_size + 1.5], [j, j], 'Color', [0 0 0]);
        end
    end
    
end 