classdef AC < sp.DataFile
    methods
        function obj = AC(filename)
            obj = obj@sp.DataFile(filename);
            obj.parse();
        end
    end

    methods (Access = private)
        parse(obj);
    end
end