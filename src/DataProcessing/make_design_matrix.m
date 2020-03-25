function xdsgn = make_design_matrix(sn_stim, rf_temporal_len)
%make_design_matrix: creates design matrix which has dimensions of nxm (rxc),
%where n = total number of stimulus (time length of the recording), 
%and m = size of the receptive field (gridsize^2 * rf temporal length)
    stim_len = size(sn_stim.stimulus,3);
    % pad with zeros at the start
    paddedStim = cat(3, zeros(sn_stim.config.gridsize,sn_stim.config.gridsize,rf_temporal_len-1), sn_stim.stimulus); 
    xdsgn = zeros(stim_len,sn_stim.config.gridsize^2*rf_temporal_len);
    % loop through the stimulus with jump size of single frame and flatten
    % to a row in the design matrix
    for j = 1:stim_len
        xdsgn(j,:) = reshape(paddedStim(:,:,j:j+rf_temporal_len-1),[1,rf_temporal_len*sn_stim.config.gridsize^2]);
    end
end