classdef Tau < sp.Data
    properties
        fits   = table;
        errors = table;
        model  = table;
    end
    
    methods (Abstract)
        fitTau(obj);
    end
    
    methods
        plot(obj, plot_type, varargin);

        %function obj = Tau(varargin) 
        %    obj = obj@sp.Data(varargin{:});
        %end
    end
end