%% adding project src
clear all
project_root_dir = '.';
addpath(genpath(fullfile(project_root_dir, 'src')));

%% load data
data_path = 'Z:\LabMembers\Jong\model_output_ts_separable\';
mat_files = dir(data_path);
save_path = 'Z:\LabMembers\Jong\model_output_ts_separable\reports\';
for idx = 3:length(mat_files)
    name = mat_files(idx).name;
    disp(name);
    load(fullfile(data_path, name));
    save_name = split(name,'.');
    save_name = save_name{1};
    temporal_rf = weight_final(1:25);
    glm_sta = reshape(weight_final(26:end), [16,16]);
    figure;
    subplot(1,2,1);
    plot_sta(glm_sta);
    title(['Spatial RF - ', strrep(name, '_', ' ')]); 
    subplot(1,2,2);
    plot(temporal_rf);
    title('Temporal RF');
    axis tight
    set(gcf, 'Units', 'Normalized', 'OuterPosition', [0.05,0.3,0.7,0.5]);
    neg_logli_test = neg_log_likli_poisson(test_var, test_lab, weight_final, 1/35, 25, 16);
    avg_logli_test = -neg_logli_test/length(test_lab);
    likeli_test = exp(avg_logli_test);
    neg_logli_train = neg_log_likli_poisson(train_var, train_lab, weight_final, 1/35, 25, 16);
    avg_logli_train = -neg_logli_test/length(train_lab);
    likeli_train = exp(avg_logli_train);
    likeli_summ = sprintf('Train Avg Likelihood - %0.3f, Test Avg Likelihood - %0.3f', likeli_train, likeli_test);
    text_ypos = min(temporal_rf)-0.1*(max(temporal_rf)-min(temporal_rf));
    text(0,text_ypos,likeli_summ);
    saveas(gcf, [save_path, save_name, '.png']);
end


function plot_sta(sta)
    colormap_path = 'Visualization\RKB.mat';
    load(colormap_path);
    levels = -1:0.1:1;
    sta = sta./max(max(abs(sta)));
    [x_size, y_size] = size(sta);
    data = zeros([x_size + 2, y_size + 2]);
    data(2 : x_size + 1, 2 : y_size + 1) = sta;
    contourf(data, levels,'LineStyle', 'none');
    colormap(color_map);
    caxis([-1 1]);
    set(gca, 'XTick', [], 'YTick', [], 'YDir', 'Rev', 'DataAspectRatioMode', 'manual', ...
    'YLim', [1.5, y_size + 1.5], 'XLim', [1.5, x_size + 1.5], 'Color', 'k', 'DataAspectRatio', [1 1 1]);
    for k = 1.5 : 1 : x_size + 1.5
        line([k, k], [1.5, x_size + 1.5], 'Color', [0 0 0]);
    end
    for j = 1.5 : 1 : y_size + 1.5
        line([1.5, y_size + 1.5], [j, j], 'Color', [0 0 0]);
    end    
end 