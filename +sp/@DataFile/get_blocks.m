function idxs = get_blocks(data, spacer)
    idxs = 1;
    for a = 2:length(data)
        if ((data(a) - data(a - 1)) > spacer)
            idxs = [idxs a];
        end
    end
    idxs = [idxs length(data)];
end