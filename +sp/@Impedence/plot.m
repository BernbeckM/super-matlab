function plot(obj, plot_type, varargin)
    data = obj.get_data();
    data_group = data.TemperatureRounded;
    model_group = obj.model_data.TemperatureRounded;
    marker = 'o';

    switch plot_type
        case 'in'
            xdata = data.Frequency;
            ydata = data.ChiIn;
            xmodel = obj.model_data.Frequency;
            ymodel = obj.model_data.ChiIn;
            xscale = 'log';
            labels = {'Frequency (Hz)', '\chi\prime (emu mol^{-1})'};
        case 'out'
            xdata = data.Frequency;
            ydata = data.ChiOut;
            xmodel = obj.model_data.Frequency;
            ymodel = obj.model_data.ChiOut;
            xscale = 'log';
            labels = {'Frequency (Hz)', '\chi\prime\prime (emu mol^{-1})'};
        case 'cole'
            xdata = data.ChiIn;
            ydata = data.ChiOut;
            xmodel = obj.model_data.ChiIn;
            ymodel = obj.model_data.ChiOut;
            xscale = 'linear';
            labels = {'\chi\prime (emu mol^{-1})', '\chi\prime\prime (emu mol^{-1})'};
        case 'arrhenius'
            return;
            if isempty(obj.fits)
                disp('data is not fit');
                return;
            end
            xdata = 1 ./ obj.fits.TemperatureRounded;
            ydata = log(obj.fits.cc_tau_1);
            xmodel = [];
            ymodel = [];
            scale = 'linear';
            labels = {'1/T', 'log(\tau)'};
    end

    p = inputParser;
    p.addParameter('Spacing', 1);
    p.parse(varargin{:});

    sp.PlotHelper.plotDataset(xdata, ydata, data_group, 'scatter', p.Results.Spacing, marker, p.Unmatched);
    sp.PlotHelper.plotDataset(xmodel, ymodel, model_group, 'line', p.Results.Spacing, marker, p.Unmatched);


    set(gca, 'XScale', xscale);
    xlabel(labels{1}); ylabel(labels{2});
end
