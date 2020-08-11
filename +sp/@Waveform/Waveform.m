classdef Waveform < sp.Impedence
    properties
        spectra = table;
    end

    properties (Access = protected)
        WaveformFieldsParsed = {'TemperatureRounded', 'Frequency', 'ChiIn', 'ChiOut', 'phi'};
        WaveformFieldsSpectra = {'TemperatureRounded', 'Datablock', 'Frequency', 'hsDFTM', 'hsDFTF'};
    end

    methods
        plot(obj, plot_type, varargin);
        
        function obj = Waveform(filename)
            obj = obj@sp.Impedence(filename); 
            obj.parse();
        end
    end
    
    methods (Access = private)
        parse(obj, waveformData);
    end
end