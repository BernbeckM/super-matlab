function plot(obj, plot_type, varargin)
    switch class(obj)
        case 'sp.AC'
            marker = 'o';
        case 'sp.Waveform'
            marker = 's';
        otherwise
            marker = '*';
    end

    group = obj.data.TemperatureRounded;
    switch plot_type
        case 'in'
            x_data = obj.data.Frequency;
            y_data = obj.data.ChiIn;
        case 'out'
            x_data = obj.data.Frequency;
            y_data = obj.data.ChiOut;
        case 'cole'
            x_data = obj.data.ChiIn;
            y_data = obj.data.ChiOut;
        otherwise
            error('unsupported plot type');
    end

    sp.PlotHelper.scatter(x_data, y_data, group, marker);
end