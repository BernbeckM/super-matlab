function data = get_data(obj)
    data = table;
    for a = 1:length(obj.datafiles)
        data = [data; obj.datafiles(a).data(:, {'TemperatureRounded', 'Frequency', 'ChiIn', 'ChiOut'})];
    end
end