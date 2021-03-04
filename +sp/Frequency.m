classdef Frequency
    properties
        ac
        waveform
    end
    
    methods
        function obj = Frequency()
            obj.ac = sp.AC();
        end
    end
end