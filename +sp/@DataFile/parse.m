function parse(obj, filename)
    data_line = 0;

    warning('OFF', 'MATLAB:table:ModifiedAndSavedVarnames');
    obj.filename = filename;
    file_id = fopen(obj.filename, 'r');
    file_head = textscan(file_id, '%s', 50, 'Delimiter', '\n');
    fclose(file_id);

    for a = 1:length(file_head{1})
        if strcmp('[Data]', file_head{1}{a})
            data_line = a;
            break;
        end
    end
    
    if ~data_line
        error('super: unknown data format');
    end
    obj.raw = readtable(obj.filename, 'HeaderLines', data_line, 'CommentStyle', {'(', ')'});
    
    instrument_idx = sp.DataFile.get_instrument_type(file_head);
    if ~instrument_idx
        error('super: unknown instrument type');
    end
    obj.instrument_type = obj.INSTRUMENT_TYPES{instrument_idx};
    
    measurement_idx = obj.get_measurement_type(file_head);
    if ~measurement_idx
        error('super: unknown measurement type');
    end
    obj.measurement_type = obj.MEASUREMENT_TYPES{measurement_idx};

    obj.raw.Properties.VariableNames(obj.LookupTable{measurement_idx}{instrument_idx}) = obj.LookupTable{measurement_idx}{end};
    
    header = [];
    for a = 1:data_line
        if strncmp(file_head{1}{a}, 'INFO', 4) && ~contains(file_head{1}{a}, 'APPNAME') && ~contains(file_head{1}{a}, 'SEQUENCE FILE') && ~contains(file_head{1}{a}, 'BACKGROUND DATA FILE:')
            header = [header; regexp(file_head{1}{a}, ',', 'split')];
        end
    end
    
    switch obj.instrument_type
        case obj.INSTRUMENT_TYPES{1}
            header = cell2table(header(:, 2)', 'VariableNames', header(:, 3)');
        case obj.INSTRUMENT_TYPES{2}
            header = cell2table(strtrim(header(:, 3)'), 'VariableNames', header(:, 2)'); 
    end

    obj.header = cell2table(header{1, obj.HeaderFields{instrument_idx}}, 'VariableNames', obj.HeaderFields{end});
    missingFields = ismissing(obj.header);
    zeroFields = str2double(obj.header{1, :}) == 0;
    badFields = missingFields | zeroFields;

    if any(badFields)
        disp([obj.filename ' missing header information (replacing with default values):'] );
        disp(obj.HeaderFields{end}(badFields));
        obj.header{:, badFields} = obj.HeaderDefaultValues(badFields);
    end
    
    obj.header.Mass = str2double(obj.header.Mass); obj.header.EicosaneMass = str2double(obj.header.EicosaneMass);
    obj.header.MolecularWeight = str2double(obj.header.MolecularWeight); obj.header.Xdm = str2double(obj.header.Xdm);
    
    obj.header.Moles = obj.header.Mass / 1000 / obj.header.MolecularWeight;
    obj.header.EicosaneMoles = obj.header.EicosaneMass / 1000 / obj.EicosaneMW;

    obj.raw = rmmissing(obj.raw, 2);

    date_changed = dir(filename);
    obj.datenum = date_changed.datenum;
end