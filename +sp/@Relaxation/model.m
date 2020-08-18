function output = model(xdata, orbach, raman, qtm, b)
    ycalc = 0;

    if (orbach)
        ycalc = ycalc + (1 / b(2)).*exp(-b(1) ./ (0.695.*xdata));
    end
    if (raman)
        ycalc = ycalc + b(1 + 2*orbach).*xdata.^b(2 + 2*orbach);
    end
    if (qtm)
        ycalc = ycalc + (1 / b(1 + 2*orbach + 2*raman));
    end

    output = ycalc;
end