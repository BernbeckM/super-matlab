function parse(obj)
    for a = 1:length(obj.datafiles)
        toAdd = array2table([obj.datafiles(a).raw{:, sp.DataFile.ACFieldsRaw}], 'VariableNames', sp.DataFile.ACFieldsRaw);

        toAdd.TemperatureRounded = round(toAdd.Temperature / 0.02) * 0.02;
        toAdd{:, {'ChiIn', 'ChiInErr', 'ChiOut', 'ChiOutErr'}} = toAdd{:, {'ChiIn', 'ChiInErr', 'ChiOut', 'ChiOutErr'}} ./ obj.datafiles(a).header.Moles;
        toDelete = (toAdd.ChiIn < -0.1) | (toAdd.ChiOut < -0.1) | (toAdd.ChiOutErr > 0.0075) | (toAdd.ChiOut > 30);
        numToDelete = nnz(toDelete);
        if numToDelete ~= 0
            toAdd(toDelete, :) = [];
            disp(['Truncated ' num2str(numToDelete) ' datapoints from ' obj.DataFiles(a).Filename]);
        end
        obj.data = [obj.data; toAdd];
    end

    reorder_idxs = [1:2, width(obj.data), 3:(width(obj.data) - 1)];
    obj.data = obj.data(:, reorder_idxs);

    obj.data = sortrows(obj.data, {'TemperatureRounded', 'Frequency'});
end