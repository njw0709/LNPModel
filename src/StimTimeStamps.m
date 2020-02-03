classdef StimTimeStamps
    properties
        recording_name %name of the recording.
        crs_file_path %path to .crs file for time synchronization b/w stim and response.
        timestamps %timing information on when each stimulus was shown w.r.t the overall experimental time.
        templength
        tempresolu
        tempframes
    end

    methods
        function stim_ts = StimTimeStamps(crs_file_path, config)
            if ~exist('crs_file_path', 'var')
                [stim_ts.recording_name, ...
                    stim_ts.crs_file_path] = StimTimeStamps.import_files();
            else
                [stim_ts.recording_name, ...
                    stim_ts.crs_file_path] = StimTimeStamps.import_files(crs_file_path);
            end
            stim_ts.timestamps = StimTimeStamps.get_stim_timestamps(stim_ts.crs_file_path, config);
            default_t = 800;
            stim_ts.templength = default_t / 1000; % in sec
            stim_ts.tempresolu = stim_ts.timestamps(3) - stim_ts.timestamps(2);
            stim_ts.tempframes = ceil(stim_ts.templength/stim_ts.tempresolu);
        end
    end
    
    methods(Static)
        function [recording_name, crs_file_path] = import_files(crs_file_path)
            if ~exist('crs_file_path', 'var')
                [crs_file_name, crs_file_dir] = uigetfile('*.crs*', ['Import associated stimulus timestamp file for ', recording_name, '(.crs)'], config_file_dir);
                crs_file_path = strcat(crs_file_dir, crs_file_name);
            else
                recording_name = StimTimeStamps.parse_recording_name(crs_file_path);
            end
        end
        
        function recording_name = parse_recording_name(crs_file_path)
            [file_path, recording_name, ext] = fileparts(crs_file_path);
            recording_name = split(recording_name,'.');
            recording_name = recording_name{1};
        end
        
        function stim_timestamps = get_stim_timestamps(crs_file_path, config)
            [crs, ~] = StimTimeStamps.get_crs(crs_file_path, config);
            timestamps = crs.ltime(2:end);
            time_delta = diff(timestamps);
            timestamps = [timestamps; timestamps(end) + time_delta(1)];
            stim_timestamps = timestamps(config.preterm:end-(config.posterm));
        end
        
        function [crs, crinfo] = get_crs(crs_file_path, config)
            % read in data from any crs file, which is in blocks of bytes
            % need to filter off drift
            % [crs, crinfo] = getcrs(dir, filename, recordsize, samprate)

            file = crs_file_path;
            recordsize = config.recordsize;
            samprate = config.samplingrate;
            fid = fopen(file, 'r');

            if fid <= 0
                error(['Can not open the file ', file])
            end

            timebyte = 4;
            numbyte = 2;
            crsize_byte = timebyte + numbyte + recordsize * 2; %    time+datanumber+data
            crsize_int = crsize_byte / 2;

            fseek(fid, 0, 1); % go to the eof
            cr_bytes = ftell(fid); % total length of crfile in bytes
            fseek(fid, 0, -1); % rewind the file

            ncrs = cr_bytes / crsize_byte;
            tmp_crs = fread(fid, [crsize_int, ncrs], 'int16');
            tmp_crs = tmp_crs';
            crs.data = tmp_crs(:, 4:crsize_int); % make them as clay's
            crs.numdata = tmp_crs(:, 3);

            %% added by Vishal (March 07)
            %%crs.numdata= abs(crs.numdata);

            fseek(fid, 0, -1); % rewind the file
            tmp_time = fread(fid, ncrs, '1*float32', (crsize_int - 2)*2); % stupid though!!!
            crs.ltime = tmp_time;

            ft = fclose(fid);
            if ft == -1
                error('Can not close file ' +file);
            end

            ldel = crs.ltime(3:ncrs) - crs.ltime(2:ncrs-1); % records time
            ldelmax = max(ldel);
            ldelmin = min(ldel);
            if (ldelmax / ldelmin) > 1.01
                disp('WARNING!! deltimes between records in getcrs have variance >1%')
            end

            runtime = sum(ldel) / (ncrs - 2);
            start_time = crs.ltime(1);
            end_time = crs.ltime(ncrs) + runtime;
            delta_time = 10000 / samprate; %sampling time is (in 0.1msec) per data
            datamax = max((max(crs.data))');
            datamin = min((min(crs.data))');

            npoints = 0;
            for i = 1:ncrs
                npoints = npoints + crs.numdata(i);
            end

            crinfo = struct('datamin', datamin, 'datamax', datamax, ...
                'start_time', start_time, 'end_time', end_time, ...
                'delta_time', delta_time, 'total_rec', ncrs, 'total_points', npoints, 'file', file);
        end
    end
end