function idx = get_measurement_type(obj, file_head)
    switch obj.instrument_type
        case obj.INSTRUMENT_TYPES{1}
            if ~isnan(obj.raw.ACMoment_emu_)
                idx = 1;
            elseif ~isnan(obj.raw.DCMomentFreeCtr_emu_)
                idx = 2;
            elseif ~isnan(obj.raw.Moment_emu_)
                idx = 4;
            else
                idx = 0;
            end
        case obj.INSTRUMENT_TYPES{2}
            if contains(file_head{1}{2}, 'AC')
                idx = 1;
            elseif contains(file_head{1}{2}, 'DC')
                idx = 2;
            elseif contains(file_head{1}{2}, 'RSO')
                idx = 3;
            elseif contains(file_head{1}{2}, 'VSM')
                idx = 4;
            else
                idx = 0;
            end
        otherwise
            idx = 0;
    end
end