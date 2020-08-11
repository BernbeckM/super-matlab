function plot(obj, plot_type, varargin)
    for a = 1:length(obj.datafiles)
        obj.datafiles(a).plot(plot_type, varargin{:});
    end
    sp.PlotHelper.set_impedence_axes(plot_type);

    if isempty(obj.model_data)
        sp.PlotHelper.make_pretty(2, 10, 1);
        warning('data is not fit');
        return
    end
    
    group = obj.model_data.TemperatureRounded;
    switch plot_type
        case 'in'
            xmodel = obj.model_data.Frequency;
            ymodel = obj.model_data.ChiIn;
        case 'out'
            xmodel = obj.model_data.Frequency;
            ymodel = obj.model_data.ChiOut;
        case 'cole'
            xmodel = obj.model_data.ChiIn;
            ymodel = obj.model_data.ChiOut;
        otherwise
            error('unsupported plot type');
    end

    sp.PlotHelper.plot(xmodel, ymodel, group);
    sp.PlotHelper.make_pretty(2, 10, 1);
end
