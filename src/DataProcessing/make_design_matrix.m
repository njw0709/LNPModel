function xdsgn = make_design_matrix(sn_stim, rf_temporal_len)
    stim_len = size(sn_stim.stimulus,3);
    paddedStim = cat(3, zeros(sn_stim.config.gridsize,sn_stim.config.gridsize,rf_temporal_len-1), sn_stim.stimulus); % pad early bins of stimulus with zero
    xdsgn = zeros(stim_len,sn_stim.config.gridsize^2*rf_temporal_len);
    for j = 1:stim_len
        xdsgn(j,:) = reshape(paddedStim(:,:,j:j+9),[1,rf_temporal_len*sn_stim.config.gridsize^2]);
    end
end