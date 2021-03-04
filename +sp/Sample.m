classdef Sample < handle
    properties
        info = struct('mass', [], 'molecular_weight', [], 'chi_dia', [], 'eicosane', []);
        sus
        mag
        tau
    end

    methods
        function instance = Sample(varargin)
            parser = inputParser();
            parser.addRequired('mass', @(x) (x > 0) && isnumeric(x) && isscalar(x));
            parser.addRequired('molecular_weight', @(x) (x > 0) && isnumeric(x) && isscalar(x));
            parser.addRequired('chi_dia', @(x) isnumeric(x) && isscalar(x));
            parser.addRequired('eicosane',  @(x) (x >= 0) && isnumeric(x) && isscalar(x));
            parser.parse(varargin{:});
            
            instance.info = parser.Results;
            instance.info.moles = instance.info.mass / 1000 / instance.info.molecular_weight;
            instance.sus = sp.Susceptibility();
            instance.mag = sp.Magnetization();
            instance.tau = sp.Tau();
        end
        
        function load(obj)
            [files, path] = uigetfile('*.dat', 'MultiSelect', 'on');
            
            if ~iscell(files), files = {files}; end
            if files{1} == 0, return; end
            
            for a = 1:length(files)
                datafile = sp.DataFile.read([path '\' files{a}]);
                switch datafile.type
                    case 'ACvsF'
                        obj.tau.frequency.ac.parse(obj.info, datafile.data);
                    case {'ACvsF', 'ACWaveform', 'DCRelaxation'}
                        disp('tau');
                    case 'MvsT'
                        obj.sus.parse(obj.info, datafile.data);
                    case 'MvsH'
                        obj.mag.parse(obj.info, datafile.data);
                end
            end
        end
        
        function clear(obj)
            obj.sus = sp.Susceptibility();
            obj.mag = sp.Magnetization();
            obj.tau = sp.Tau();
        end
    end
end