classdef AC < sp.DataFile
    methods
        function obj = AC(filename)
            obj = obj@sp.DataFile(filename);
            obj.parse();
            %{
            [obj, updated] = obj.update(filename);
            if updated || isempty(obj.data)
                obj.parse();
            end
            %}
        end
    end

    methods (Access = private)
        parse(obj);
    end
end