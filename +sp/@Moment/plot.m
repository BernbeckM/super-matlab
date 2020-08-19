function plot(obj, plot_type, varargin)
    marker = 'o';

    switch plot_type
        case 'mag'
            group = obj.data.TemperatureRounded;
            xdata = obj.data.Field ./ 10000;
            ydata = obj.data.MomentEff;
        case 'sus'
            idxs = sp.DataFile.get_blocks(obj.data.Time, 200);
            group = cell2mat(arrayfun(@(x) ones(idxs(x) - idxs(x - 1) + 1, 1), 2:length(idxs), 'UniformOutput', false));
            xdata = obj.data.Temperature;
            ydata = obj.data.ChiT;
        otherwise
            error('unsupported plot type');
    end

    sp.PlotHelper.scatter(xdata, ydata, group, marker);
end