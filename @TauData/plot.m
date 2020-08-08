function plot(obj, plot_type, varargin)
    switch plot_type
        case 'arrhenius'
            xdata = 1./obj.Fits.TemperatureRounded;
            columns = obj.Fits(:, contains(obj.Fits.Properties.VariableNames, 'tau'));
            ydata = log(reshape(table2array(columns), [height(obj.Fits)*width(columns), 1]));
            xdata = repmat(xdata, width(columns), 1);
            xscale = 'linear';
            data_group = repmat(obj.Fits.TemperatureRounded, 1, width(columns));
            labels = {'1/T', 'ln(\tau)'};
        otherwise
            disp('Unrecognized plot type, supported: in, out, cole, arrhenius');
            return;
    end

    p = inputParser;
    p.addParameter('Spacing', 1);
    p.addParameter('Errors', 0);
    p.parse(varargin{:});
    
    switch class(obj)
        case 'ACData'
            marker = 'o';
        case 'WaveformData'
            marker = 'square';
        otherwise
            marker = '*';
    end

    PlotHelper.plotDataset(xdata, ydata, data_group, 'scatter', p.Results.Spacing, marker, p.Unmatched);
    set(gca, 'XScale', xscale);
    xlabel(labels{1}); ylabel(labels{2});
    
    if p.Results.Errors
        neg = obj.Errors(:, contains(obj.Errors.Properties.VariableNames, 'tau_ci_neg'));
        neg = reshape(table2array(neg), [height(obj.Fits)*width(neg), 1]);
        pos = obj.Errors(:, contains(obj.Errors.Properties.VariableNames, 'tau_ci_pos'));
        pos = reshape(table2array(pos), [height(obj.Fits)*width(pos), 1]);
        ydata = reshape(table2array(columns), [height(obj.Fits)*width(columns), 1]);
        (pos - ydata) * 1000
        errorbar(xdata, log(ydata), log(ydata) - log(neg), log(pos) - log(ydata), 'LineStyle', 'none', 'HandleVisibility', 'off');
    end
end