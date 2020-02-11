%% add src code
project_root_dir = '.';
addpath(genpath(fullfile(project_root_dir, 'src')));

%% list of interneurons
interneurons = {
'190417C_clu12', '190417C_clu21','190510A_clu5','190510A_clu20',...
'190510A_clu59','190510A_clu70','190523A_clu29','190523A_clu41',...
'190523A_clu60','190523A_clu63','190917A_clu7',...
'190917A_clu28','190917A_clu30','190917A_clu31','190917A_clu33',...
'190917A_clu43','190917A_clu45','190917A_clu46','190917A_clu67'};

data_root_path = 'Z:\LabMembers\Jong\Interneuron_multie\';
config_root_path = 'SN\processed';
event_timing_path = 'SN';
train_data_pct = 0.7;
save_path = 'Z:\LabMembers\Jong\model_output_ts_separable\';

defaultprs = {'Gradobj','on', 'maxiter', 1000, 'maxfunevals', 1e9, 'Display', 'iter', 'UseParallel', true};
opts = optimset(defaultprs{:});

for i=3:length(interneurons)
    experiment_name = split(interneurons{i},'_');
    clu_name = experiment_name{2};
    experiment_name = experiment_name{1};
    data_path = fullfile(data_root_path, experiment_name);
    config_path = fullfile(data_path, config_root_path);
    
    config_files = dir(fullfile(config_path, '*.m'));
    for j=1:length(config_files)
        recording_name = config_files(j).name;
        recording_name = split(recording_name,'.');
        recording_name = recording_name{1};
        save_file_name = fullfile(save_path, [interneurons{i},'_',recording_name,'.mat']);
        try
           dataset = create_dataset(clu_name, recording_name, data_path);
           [train_var, train_lab, test_var, test_lab] = dataset.divide_train_test_data(train_data_pct);
           sta = (train_var'*train_lab)/sum(train_lab);
           sta = reshape(sta, [16,16,25]);
           Loss = @(rf_weights) neg_log_likli_poisson(train_var, train_lab, rf_weights, stim_ts.tempresolu, rf_temporal_len, configs.config.gridsize);
           init_weight = initialize_weight_from_sta(sta, 'separable');
           [weight_final,neglogli,exitflag] = fminunc(Loss,init_weight,opts);
           if (exitflag == 0)
               fprintf('max # evaluations or iterations exceeded (fminunc)\n');
           end
           save(save_file_name, 'weight_final', 'train_var', 'train_lab', 'test_var', 'test_lab');
        catch
           disp(['error while running ', experiment_name,' ', recording_name,'_', clu_name]);
        end
    end
    
end

function dataset = create_dataset(clu_name, recording_name, data_path)
    config_root_path = 'SN\processed';
    event_timing_path = 'SN';
    config_file_path = fullfile(data_path, config_root_path, [recording_name,'.m']);
    crs_file_path = fullfile(data_path, config_root_path, [recording_name,'.ch4.crs']);
    event_timing_file_path = fullfile(data_path, event_timing_path, [recording_name, '_', clu_name, '.txt']);
    
    configs = Config(config_file_path);
    sn_stim = SparseNoiseStimulus(configs.config);
    stim_ts = StimTimeStamps(crs_file_path, configs.config);
    spike_times = SpikeTimes(event_timing_file_path);
    [tbin_centers, binned_spikes] = hist_bin_spikes(stim_ts, spike_times);
    rf_temporal_len = 25; % frames
    Xdsgn = make_design_matrix(sn_stim, rf_temporal_len);
    dataset = DataSet(Xdsgn, binned_spikes);
end