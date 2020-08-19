classdef Magnetization
    properties
        datafiles = [];
    end
    
    methods
        load(obj);
        function plot(obj, varargin)
            for a = 1:length(obj.datafiles)
                obj.datafiles(a).plot('mag');
            end
        end

        function data = get_data(obj)
            data = table;
            for a = 1:length(obj.datafiles)
                to_add = obj.datafiles(a).data(:, {'Temperature', 'TemperatureRounded', 'Field', 'Moment'});
                data = [data; to_add];
            end
        end
        
        function obj = Magnetization(varargin)
            for a = 1:length(varargin)
                obj.datafiles = [obj.datafiles; sp.Moment(varargin{a})];
            end
        end
    end
end