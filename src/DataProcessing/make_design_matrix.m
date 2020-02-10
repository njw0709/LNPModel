function xdsgn = make_design_matrix(sn_stim, rf_temporal_len)
    stim_len = size(sn_stim.stimulus,3);
    flattened_stim = reshape(sn_stim.stimulus, [stim_len, sn_stim.config.gridsize^2]);
    paddedStim = [zeros(rf_temporal_len-1,sn_stim.config.gridsize^2); flattened_stim]; % pad early bins of stimulus with zero
    paddedStim = reshape(paddedStim,size(paddedStim,1)*size(paddedStim,2),1);
    xdsgn = zeros(stim_len,sn_stim.config.gridsize^2*rf_temporal_len);
    for j = 1:stim_len
        %sliding window with jump size of gridsize^2 and window
        %size of gridsize^2*rf_temporal_len
        xdsgn(j,:) = paddedStim(1+(j-1)*sn_stim.config.gridsize^2:(j-1)* ...
        sn_stim.config.gridsize^2+rf_temporal_len*sn_stim.config.gridsize^2)';
    end
end