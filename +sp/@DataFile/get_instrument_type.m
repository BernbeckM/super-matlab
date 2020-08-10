function idx = get_instrument_type(file_head)
    if contains(file_head{1}{2}, 'MPMS3')
        idx = find(contains(sp.DataFile.INSTRUMENT_TYPES, 'MPMS3'));
    elseif contains(file_head{1}{2}, 'TITLE,MPMS')
        idx = find(contains(sp.DataFile.INSTRUMENT_TYPES, 'MPMSXL'));
    else
        idx = 0;
    end
end