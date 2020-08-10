classdef Sample < handle
    properties
        name = '';
        imp = sp.Impedence();
        %mag = sp.Magnetization();
        %sus = sp.Susceptibility();
    end

    methods
        function obj = Sample(name)
            % TODO: implement parser
            obj.name = name;
        end

        function load_data(obj, type)
            
        end
    end
end