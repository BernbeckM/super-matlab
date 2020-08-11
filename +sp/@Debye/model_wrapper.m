function output = model_wrapper(xdata, cc, hn, b)
    ycalc = sp.Debye.model(xdata, cc, hn, b);
    yreal = real(ycalc);
    yimag = -imag(ycalc);

    output(:, 1) = yreal;
    output(:, 2) = yimag;
end