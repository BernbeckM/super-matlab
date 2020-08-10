function plot(obj, varargin)
    p = inputParser;
    p.addParameter('Temperature', min(obj.Parsed.TemperatureRounded));
    p.parse(varargin{:});
    PlotHelper.plotDataset(obj.Spectra.Frequency, abs(obj.Spectra.hsDFTM), obj.Spectra.Datablock, 'line', 3, '*', p.Unmatched);
    set(gca, 'XScale', 'log');
end