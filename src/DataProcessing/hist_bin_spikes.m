function [tbin_centers, binned_spike_train] = hist_bin_spikes(stim_ts,spike_times)
%his_bin_spikes: bins the spikes w.r.t the timestamps of the visual
%stimulus.
%Input: stim_ts - instance of StimTimeStamps, spike_times -
%instance of SpikeTimes. Output: tbin_centers - centers of the histogram bins,
%binned_spike_train: histogram counts of the spikes within each bin.
    tbin_centers = conv(stim_ts.timestamps, [0.5 0.5], "valid"); % time bin centers for spike train binnning
    binned_spike_train = hist(spike_times.spike_t_vector,tbin_centers)'; % binned spike train
end
