function parse(obj)
    toAdd = array2table([obj.raw{:, sp.DataFile.ACFieldsRaw}], 'VariableNames', sp.DataFile.ACFieldsRaw);

    toAdd.TemperatureRounded = round(toAdd.Temperature / 0.02) * 0.02;
    toAdd{:, {'ChiIn', 'ChiInErr', 'ChiOut', 'ChiOutErr'}} = toAdd{:, {'ChiIn', 'ChiInErr', 'ChiOut', 'ChiOutErr'}} ./ obj.header.Moles;
    toDelete = (toAdd.ChiIn < -0.1) | (toAdd.ChiOut < -0.1) | (toAdd.ChiOutErr > 0.0075) | (toAdd.ChiOut > 30);
    numToDelete = nnz(toDelete);
    if numToDelete ~= 0
        toAdd(toDelete, :) = [];
        disp(['truncated ' num2str(numToDelete) ' datapoints from ' obj.filename]);
    end
    obj.data = [obj.data; toAdd];

    reorder_idxs = [1:2, width(obj.data), 3:(width(obj.data) - 1)];
    obj.data = obj.data(:, reorder_idxs);

    obj.data = sortrows(obj.data, {'TemperatureRounded', 'Frequency'});
end