classdef Impedence < handle
    properties
        datafiles   = [];
        fits        = table;
        model_data  = cell2table(cell(0,4), 'VariableNames', {'TemperatureRounded', 'Frequency', 'ChiIn', 'ChiOut'});
        model_error = table;
    end

    methods
        fit(obj, varargin);
        data = get_data(obj);
        load(obj, type);
        plot(obj, plot_type, varargin);
    end

    methods (Static)
        output = CC(b, omega);
        output = HN(b, omega);
        output = model(xdata, cc, hn, b);
        output = model_wrapper(xdata, cc, hn, b);
        output = objective(xdata, ydata, cc, hn, b);
    end
end