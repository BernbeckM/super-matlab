function plot(obj, plot_type, varargin)
    if isempty(obj.model_data)
        warning('data is not fit');
    else
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
            case 'arrhenius'
                group = obj.fits.TemperatureRounded;
                xmodel = 1 ./ obj.fits.TemperatureRounded;
                ymodel = log(obj.fits.cc_tau_1);
                sp.PlotHelper.scatter(xmodel, ymodel, group, 'd');
                return
            otherwise
                error('unsupported plot type');
        end
        sp.PlotHelper.plot(xmodel, ymodel, group);
    end
    
    for a = 1:length(obj.datafiles)
        obj.datafiles(a).plot(plot_type, varargin{:});
    end
    sp.PlotHelper.set_impedence_axes(plot_type);
end
