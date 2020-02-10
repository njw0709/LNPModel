function [tbin_centers, binned_spike_train] = hist_bin_spikes(stim_ts,spike_times)
    tbin_centers = conv(stim_ts.timestamps, [0.5 0.5], "valid"); % time bin centers for spike train binnning
    binned_spike_train = hist(spike_times.spike_t_vector,tbin_centers)'; % binned spike train
end
