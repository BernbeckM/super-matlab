function plot(obj, plot_type, varargin)
    group = obj.spectra.Datablock;
    switch plot_type
        case 'fftm'
            xdata = obj.spectra.Frequency;
            ydata = abs(obj.spectra.hsDFTM);
            labels = {'Frequency (Hz)', 'FFT(Moment)'};
        case 'fftf'
            xdata = obj.spectra.Frequency;
            ydata = abs(obj.spectra.hsDFTF);
            labels = {'Frequency (Hz)', 'FFT(Field)'};
        otherwise
            plot@sp.Impedence(obj, plot_type, varargin{:});
            return
    end
    sp.PlotHelper.plot(xdata, ydata, group);
    set(gca, 'XScale', 'log');
    xlabel(labels{1}); ylabel(labels{2});
end