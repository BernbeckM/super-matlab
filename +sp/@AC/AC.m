classdef AC < sp.Impedence
    methods
        function obj = AC(filename)
            obj = obj@sp.Impedence(filename);
            obj.parse();
        end
    end

    methods (Access = private)
        parse(obj);
    end
end