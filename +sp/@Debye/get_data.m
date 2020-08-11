function data = get_data(obj)
    data = table;
    for a = 1:length(obj.datafiles)
        run_type = string(class(obj.datafiles(a)));
        to_add = obj.datafiles(a).data(:, {'TemperatureRounded', 'Frequency', 'ChiIn', 'ChiOut'});
        to_add.RunType = repmat(run_type, height(to_add), 1);
        data = [data; to_add];
    end
end