classdef DataFile
    methods (Static)
        function output = read(filename, varargin)
            data = sp.DataFile.parse_data(filename);
            
            output = struct();
            output.data = data;
            output.type = sp.DataFile.get_datafile_type(data(1:40, :));
        end
        
        function data = parse_data(filename)
            file_id = fopen(filename, 'r');
                data_line_number = sp.DataFile.get_data_line(file_id);
                data_header_line = textscan(file_id, '%s', 1, 'Delimiter', '\n', 'HeaderLines', data_line_number);
                variable_names = split(data_header_line{1}, ',');
                format_spec = repmat('%f', 1, 89);
                data = textscan(file_id, format_spec, 'Delimiter', ',', 'EmptyValue', NaN, 'CollectOutput', true);
            fclose(file_id);
            
            data = array2table(data{1}, 'VariableNames', variable_names');
            data = sp.DataFile.clean(data);
        end
        
        function cleaned = clean(data)
            empty_columns = isnan(data{1, :});
            cleaned = data(:, ~empty_columns);
            
            old_names = {'DC Moment Free Ctr (emu)', 'DC Moment Err Free Ctr (emu)'};
            new_names = {'Moment (emu)', 'M. Std. Err. (emu)'};
            
            if ismember(old_names{1}, cleaned.Properties.VariableNames)
                [~, ~, column_numbers] = intersect(old_names, cleaned.Properties.VariableNames);
                cleaned.Properties.VariableNames(column_numbers) = new_names;
            end
        end
        
        function line_number = get_data_line(file_id)
            file_head = textscan(file_id, '%s', 50, 'Delimiter', '\n');
            for a = 1:length(file_head{1})
                if strcmp('[Data]', file_head{1}{a})
                    line_number = a;
                    break;
                end
            end
            
            frewind(file_id);
        end
        
        function datafile_type = get_datafile_type(data)
            is_changing = @(x) std(x) > 0.2;
            
            if ismember('AC Frequency (Hz)', data.Properties.VariableNames)
                if is_changing(data{:, 'Temperature (K)'})
                    datafile_type = 'ACvsT';
                elseif is_changing(data{:, 'Magnetic Field (Oe)'})
                    datafile_type = 'ACvsH';
                elseif is_changing(data{:, 'AC Frequency (Hz)'})
                    datafile_type = 'ACvsF';
                else
                    datafile_type = 'ACvsUnknown';
                end
            else
                if is_changing(data{:, 'Temperature (K)'})
                    datafile_type = 'MvsT';
                elseif rms(data{:, 'Magnetic Field (Oe)'}) <= 2
                    datafile_type = 'DCRelaxation';
                elseif rms(data{:, 'Magnetic Field (Oe)'}) > 2
                    if max(data{:, 'Magnetic Field (Oe)'}) < 16
                        datafile_type = 'ACWaveform';
                    else
                        datafile_type = 'MvsH';
                    end
                else
                    datafile_type = 'Unknown';
                end
            end
        end
    end
end