classdef AC < sp.Run
    methods
        function parsed = parse(obj, info, raw_data)
            parsed = parse@sp.Run(raw_data);
            
            parsed{:, 'Temperature (K)'} = round(parsed{:, 'Temperature (K)'}, 1);
            parsed{:, 'AC Frequency (Hz)'} = raw_data{:, 'AC Frequency (Hz)'};
            
            obj.data = [obj.data; parsed];
        end
    end
end