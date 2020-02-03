classdef SparseNoiseStimulus
    properties
        snf_file_dir %.snf file contains information needed to reconstruct the pseudo-randomly generated sparse noise stim
        config %configurations read / computed from .m and .snf files
        stimulus %reconstructed sparse noise stimulus (matrix)
    end
    
    methods
        function sn_stim = SparseNoiseStimulus(config)
            sn_stim.snf_file_dir = '.\data\snf\';
            sn_stim.config = config;
            sn_stim.stimulus = SparseNoiseStimulus.recreate_snf(sn_stim.snf_file_dir, sn_stim.config);
        end
    end
    
    methods (Static)
        function stim = recreate_snf(snf_file_path, config)
            snf_file = fullfile(snf_file_path, config.snfilename);
            [snra] = SparseNoiseStimulus.read_snf(snf_file);

            % Only for get snpars
            snpars = SparseNoiseStimulus.cedmakesnpars(config);

            % snpars.snmod is 16*16*2 actually.
            aftermod = mod(snra-1, snpars.snmod);
            row = floor(aftermod/(snpars.ncols * 2)) + 1; % instead of ceil. matlab begin with 1
            coln = mod(aftermod, snpars.ncols*2);
            col = floor(coln/2) + 1;
            sign = 1 - mod(coln, 2) * 2; % 0 -> 1 for white ; 1(odd) -> -1 for black

            stim = zeros(config.gridsize, config.gridsize, length(snra), 'int8');
            for i = 1:length(snra)
                stim(row(i), col(i), i) = sign(i);
            end
        end

        function snpars = cedmakesnpars(config)
            nrows = config.gridsize;
            ncols = config.gridsize;
            bintime = config.refreshrate;
            contrast = config.contrastness;
            snmod = nrows * ncols * 2;

            snpars = struct('bintime', bintime, 'nrows', nrows, 'ncols', ncols, ...
                'snmod', snmod, 'sncurpt', 0, 'row', 0, 'col', 0, 'sign', 0, 'contrast', contrast);
        end

        function [snra, orderpoly, maskpoly, norder, basepoly] = read_snf(file)
            %file = [condir,'\',filename];
            fid = fopen(file, 'r');
            if fid <= 0
                %    file = strrep (file, '\', '\\');
                error(['Can not open the file ', file])
            else
                norder = fread(fid, 1, 'int16');
                basepoly = fread(fid, 1, 'int32');
                snra = fread(fid, inf, 'int16');
            end

            ft = fclose(fid);
            if ft == -1
                error('Can not close file ' +file);
            end

            orderpoly = 2^(norder - 1); %int32(2^(norder-1))
            maskpoly = 2^norder - 1; %int32(2^norder-1)
        end
    end
end