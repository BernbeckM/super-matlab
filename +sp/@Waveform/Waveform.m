classdef Waveform < sp.DataFile
    properties
        spectra = table;
    end

    properties (Access = protected)
        WaveformFieldsParsed = {'TemperatureRounded', 'Frequency', 'ChiIn', 'ChiOut', 'phi'};
        WaveformFieldsSpectra = {'TemperatureRounded', 'Datablock', 'Frequency', 'hsDFTM', 'hsDFTF'};
    end

    methods
        parse(obj, waveformData);

        function obj = Waveform(filename)
            obj = obj@sp.DataFile(filename); 
            obj.parse();
        end

        function plot(obj)

        end
    end
end