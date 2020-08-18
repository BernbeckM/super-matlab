classdef Debye < handle
    properties
        datafiles   = [];
        fits        = table;
        model_data  = cell2table(cell(0,4), 'VariableNames', {'TemperatureRounded', 'Frequency', 'ChiIn', 'ChiOut'});
        model_error = table;
    end

    properties (Access = private)
        fmincon_opts = optimoptions(@fmincon, ...
            'Algorithm', 'interior-point', ...
            'FunctionTolerance', 1e-24, 'OptimalityTolerance', 1e-24, 'StepTolerance', 1e-24, ...
            'ObjectiveLimit', 1e-24, 'Display', 'off', 'ConstraintTolerance', 1E-24);
        lsqcurvefit_opts = optimoptions('lsqcurvefit', ...
            'Algorithm', 'Levenberg-Marquardt', ...
            'FunctionTolerance', 1e-10, 'OptimalityTolerance', 1e-10, 'StepTolerance', 1e-10, ...
            'Display', 'off');
        gs = GlobalSearch('MaxTime', 45, 'Display', 'off', 'NumStageOnePoints', 200, 'NumTrialPoints', 1000);
    end
    
    methods
        fit(obj, varargin);
        data = get_data(obj);
        load(obj);
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