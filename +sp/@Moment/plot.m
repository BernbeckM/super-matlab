function plot(obj, plot_type, varargin)
    marker = 'o';

    switch plot_type
        case 'mag'
            group = obj.data.TemperatureRounded;
            xdata = obj.data.Field ./ 10000;
            ydata = obj.data.MomentEff;
        case 'sus'
            idxs = sp.DataFile.get_blocks(obj.data.Time, 400);
            group = cell2mat(arrayfun(@(x) ones(idxs(x) - idxs(x - 1) + 1, 1), 2:length(idxs), 'UniformOutput', false));
            xdata = obj.data.Temperature;
            ydata = obj.data.ChiT;
            xlabel('Temperature (K)'); ylabel('\chiT (emu mol^{-1} K)');
        otherwise
            error('unsupported plot type');
    end

    sp.PlotHelper.plot(xdata, ydata, group);
end