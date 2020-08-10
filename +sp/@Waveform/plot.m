function plot(obj, plot_type, varargin)
    switch plot_type
        case 'spectra'
            p = inputParser;
            p.addParameter('Temperature', min(obj.Parsed.TemperatureRounded));
            p.parse(varargin{:});
            %rows = obj.Spectra.TemperatureRounded == p.Results.Temperature;
            PlotHelper.plotDataset(obj.Spectra.Frequency, abs(obj.Spectra.hsDFTM), obj.Spectra.Datablock, 'line', 3, '*', p.Unmatched);
            set(gca, 'XScale', 'log');
        otherwise
            plot@DebyeData(obj, plot_type, varargin{:});
    end
end