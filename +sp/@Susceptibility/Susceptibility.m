classdef Susceptibility < sp.DataFile
    properties
        datafiles = [];
    end
    
    methods
        data = get_data(obj);
        load(obj);
        plot(obj, plot_type, varargin);
    end
end