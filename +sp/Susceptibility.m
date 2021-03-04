classdef Susceptibility < sp.Static
    methods
        function parse(obj, info, raw_data)
            parsed = parse@sp.Static(info, raw_data);
            
            parsed{:, {'chi (emu/mol)', 'chi Std. Err. (emu/mol)'}} = ...
                parsed{:, {'Moment (emu/mol)', 'M. Std. Err. (emu/mol)'}} ./ ...
                parsed{:, {'Magnetic Field (Oe)'}};
            
            parsed{:, {'chiT (emuK/mol)', 'chiT Std. Err. (emuK/mol)'}} = ...
                parsed{:, {'chi (emu/mol)', 'chi Std. Err. (emu/mol)'}} .* ...
                parsed{:, {'Temperature (K)'}};
            
            obj.data = [obj.data; parsed];
        end
        
        function plot(obj)
            plot(obj.data.("Temperature (K)"), obj.data.("chiT (emuK/mol)"));
        end
    end
end