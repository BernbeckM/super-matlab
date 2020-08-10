classdef Waveform < sp.DataFile
    properties
        spectra = table;
    end

    properties (Access = protected)
        WaveformFieldsParsed = {'TemperatureRounded', 'Frequency', 'ChiIn', 'ChiOut', 'phi'};
        WaveformFieldsSpectra = {'TemperatureRounded', 'Datablock', 'Frequency', 'hsDFTM', 'hsDFTF'};
    end

    methods
        function obj = Waveform(filename)
            obj = obj@sp.DataFile(filename); 
            obj.parse();
        end
    end
    
    methods (Access = private)
        parse(obj, waveformData);
    end
end