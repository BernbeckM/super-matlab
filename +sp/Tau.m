classdef Tau
    properties
        frequency
        time
    end
    
    methods
        function obj = Tau()
            obj.frequency = sp.Frequency();
        end
    end
    
    methods (Static)

    end
end