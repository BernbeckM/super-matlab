function output = objective(xdata, ydata, cc, hn, b)
    ycalc = sp.Impedence.model(xdata, cc, hn, b);
    yreal = real(ycalc);
    yimag = -imag(ycalc);

    output = sum((ydata(:, 1) - yreal).^2) + sum((ydata(:, 2) - yimag).^2);
end