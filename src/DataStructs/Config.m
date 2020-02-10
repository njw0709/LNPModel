classdef Config   
    properties
        recording_name
        config_file_path
        config
    end
    
    methods
        function obj = Config(config_file_path)
            if ~exist('config_file_path', 'var')
                disp('Specified no files to import.');
                [obj.recording_name, ...
                    obj.config_file_path] = Config.import_files();
            else
                [obj.recording_name, ...
                    obj.config_file_path] = Config.import_files(config_file_path);
            end
            obj.config = Config.build_config(obj.config_file_path);
        end
    end
     methods (Static)
        function [recording_name, config_file_path] = import_files(config_file_path)
            if ~exist('config_file_path', 'var')
                [m_file_name, config_file_dir] = uigetfile('*.m*', 'Import sparse noise config file (*.m)');
                recording_name = Config.parse_recording_name(m_file_name);
                config_file_path = strcat(config_file_dir, m_file_name);
            else
                recording_name = Config.parse_recording_name(config_file_path);
            end
        end
        function recording_name = parse_recording_name(m_file_name)
            [file_path, recording_name, ext] = fileparts(m_file_name);
        end
        function config = build_config(config_file_path)
            run(config_file_path);

            % Then if it is a sn stimulus we have:
            % preterm posterm frmperterm  refreshrate

            arg = who;
            config = struct;
            for i = 1:length(arg)
                %arg(i) is still a cell, needs to be converted to str.
                eval(['config.', cell2mat(arg(i)), '=', cell2mat(arg(i)), ';']);
            end
        end
     end
end

