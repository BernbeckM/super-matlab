classdef Magnetization < sp.Static
    methods
        function parse(obj, info, raw_data)
            parsed = parse@sp.Static(info, raw_data);
            
            parsed{:, {'Magnetization (uB/mol)', 'Magnetization Std. Err. (uB/mol)'}} = ...
                parsed{:, {'Moment (emu/mol)', 'M. Std. Err. (emu/mol)'}} ./ ...
                5585;
            
            parsed{:, 'Temperature (K)'} = round(parsed{:, 'Temperature (K)'}, 1);
            
            obj.data = [obj.data; parsed];
        end
        
        function plot(obj)
            plot(obj.data.("Magnetic Field (Oe)"), obj.data.("Magnetization (uB/mol)"));
        end
    end
end