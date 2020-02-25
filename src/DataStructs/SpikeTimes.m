classdef SpikeTimes
    % Reads and parses the .txt file with timestamps of spikes.
    % Timestamps are recorded in reference to the universal recording time.
    properties
        recording_name %name of the recording
        event_timing_file_path %file path of the event timing .txt file
        spike_t_vector %spike timing vector
        t0 %when the recording started in universal time
    end
    
    methods
        function spike_times = SpikeTimes(event_timing_file_path)
            if ~exist('event_timing_file_path', 'var')
                [spike_times.recording_name, ...
                    spike_times.event_timing_file_path] = SpikeTimes.import_file();
            else
                [spike_times.recording_name, ...
                    spike_times.event_timing_file_path] = SpikeTimes.import_file(event_timing_file_path);
            end
            [spike_times.spike_t_vector, ...
                spike_times.t0] = SpikeTimes.parse_data(spike_times.event_timing_file_path);
        end

    end

    methods (Static)
        function [recording_name, event_timing_file_path] = import_file(event_timing_file_path)
            if ~exist('event_timing_file_path', 'var')
                [txt_file_name, txt_file_path] = uigetfile('*.txt*', 'Import Event Timing File');
                event_timing_file_path = strcat(txt_file_path, txt_file_name);
                recording_name = SpikeTimes.parse_recording_name(event_timing_file_path);
            else
                recording_name = SpikeTimes.parse_recording_name(event_timing_file_path);
            end
        end

        function recording_name = parse_recording_name(event_timing_file_path)
            [file_path, recording_name, ext] = fileparts(event_timing_file_path);
        end

        function [spike_t_vector, t0] = parse_data(event_timing_file_path)
            spike_t_vector = textread(event_timing_file_path);
            t0 = spike_t_vector(1);
            spike_t_vector = spike_t_vector(2:length(spike_t_vector));
            spike_t_vector = sort(spike_t_vector);
        end
    end
end