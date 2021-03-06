function [weight] = initialize_weight_from_sta(sta,opt)
%INITIALIZE_WEIGHT_FROM_STA initializes the weight from spike triggered
%average to be used as the first guess of the glm. If opt = 'separable', 
%it creates weights with time-space separated, and returns an array with 
%the two concatenated.
    if isequal(opt, 'separable')
        amplitudes = sum(abs(sta), [1,2]);
        [M,I] = max(amplitudes(:));
        spatial_rf_init = reshape(sta(:,:,I), size(sta,1)*size(sta,2),1);
        temporal_rf_init = reshape(amplitudes./M, size(amplitudes,3),1);
        weight = [temporal_rf_init; spatial_rf_init];
    else
        weight = reshape(sta, size(sta,1)*size(sta,2)*size(sta,3),1);
    end
end

