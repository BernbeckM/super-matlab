function output = objective(xdata, ydata, orbach, raman, qtm, b)
    ycalc = log(sp.Relaxation.model(xdata, orbach, raman, qtm, b));

    output = sum((ydata - ycalc).^2);
end