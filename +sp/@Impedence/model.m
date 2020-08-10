function output = model(xdata, cc, hn, b)
    ycalc = 0;

    for a = 1:cc
        ycalc = ycalc + sp.Impedence.CC([b(((a - 1) * 3 + 1):((a - 1) * 3 + 3)), b(end)], xdata);
    end

    for a = 1:hn
        ycalc = ycalc + sp.Impedence.HN([b(((a - 1) * 4 + 1 + (cc * 3)):((a - 1) * 4 + 4 + (cc * 3))), b(end)], xdata);
    end

    output = b(end) + ycalc;
end