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
save_path = 'Z:\LabMembers\Jong\model_output\';

opts=statset('glmfit');
opts.MaxIter = 5000; 
opts.UseParallel = true;

for i=3:length(interneurons)
    experiment_name = split(interneurons{i},'_');
    clu_name = experiment_name{2};
    experiment_name = experiment_name{1};
    save_file_name = fullfile(save_path, [interneurons{i},'.mat']);
    data_path = fullfile(data_root_path, experiment_name);
    config_path = fullfile(data_path, config_root_path);
    
    config_files = dir(fullfile(config_path, '*.m'));
    for j=1:length(config_files)
        recording_name = config_files(j).name;
        recording_name = split(recording_name,'.');
        recording_name = recording_name{1};
        try
            if j==1
               dataset = create_dataset(clu_name, recording_name, data_path);
            else
               dataset2 = create_dataset(clu_name, recording_name, data_path);
               dataset = dataset.join(dataset2);
            end            
        catch
            disp(['error while running ', experiment_name,' ', recording_name,'_', clu_name]);
        end
    end
    [train_var, train_lab, test_var, test_lab] = dataset.divide_train_test_data(train_data_pct);
    glm_weight = glmfit(train_var, train_lab, 'poisson','constant', 'on', 'options', opts);
    save(save_file_name, 'glm_weight', 'test_var', 'test_lab');
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