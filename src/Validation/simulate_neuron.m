function [spike_train, rf_spatial, rf_temporal] = simulate_neuron(Stim)
    rf_temporal_len = 25;
    spatial_amplitude = 1.6;
    rf_spatial = spatial_amplitude.*center_surround(1.2, [6,7]);
    rf_spatiotemporal = repmat(rf_spatial,[1,1,rf_temporal_len]);
    rf_temporal = [0,0,0,0,-0.1,-0.2,-0.25,-0.3,-0.4,-0.3,-0.1,0,0,0.1,0.2,0.3,0.5,0.8,0.9,1,0.8,0.6,0.4,0.3,0.2];
    NL = @(x) ReLUAct(x);
    %% scale rf_spatial with temporal
    for k=1:25
        rf_spatiotemporal(:,:,k) = rf_spatiotemporal(:,:,k)*rf_temporal(k);
    end
    %% flatten
    flattened_rf = reshape(rf_spatiotemporal,16^2*rf_temporal_len, 1); 
    %% create spike train
    spike_train = zeros(size(Stim,2),1);
    recon_rf = reshape(flattened_rf, 16, 16, rf_temporal_len);
    for i=1:size(Stim,1)
         spike_train(i) = poissrnd(NL(Stim(i,:)*flattened_rf));
    end
end

function res = ReLUAct(x)
    if x>0
        res = x;
    else
        res = 0;
    end
end

function rf = center_surround(sigma, center)
    x0 = center(1);
    y0 = center(2);
    [R,C] = ndgrid(1:16, 1:16);
    sigma_surround = sigma*1.8;
    rf_center = 1.3.*exp(-((R-x0)./(2*sigma)).^2 - ((C-y0)./(2*sigma)).^2);
    rf_surround = 0.3.*exp(-((R-x0)./(2*sigma_surround)).^2 - ((C-y0)./(2*sigma_surround)).^2);
    rf = rf_center-rf_surround;
end