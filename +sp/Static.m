classdef Static < sp.Run
    methods (Static)
        function parsed = parse(info, raw_data)
            parsed = parse@sp.Run(raw_data);

            parsed{:, {'Moment (emu/mol)', 'M. Std. Err. (emu/mol)'}} = ...
                raw_data{:, {'Moment (emu)', 'M. Std. Err. (emu)'}} ./ ...
                info.moles;
        end
    end
end