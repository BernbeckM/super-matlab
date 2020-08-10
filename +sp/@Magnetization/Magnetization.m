classdef Magnetization < sp.DataFile

    methods
        function obj = Magnetization(filename)
            obj = obj@sp.Data(filename);
            %obj.parseMagnetizationData();
        end

        plot(obj, varargin);
    end
    %{
    methods (Access = private)
        parseMagnetizationData(obj);
    end
    %}
end