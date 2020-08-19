function output = objective(xdata, ydata, orbach, raman, qtm, dipole, b)
    ycalc = log(sp.Relaxation.model(xdata, orbach, raman, qtm, dipole, b));

    output = sum((ydata - ycalc).^2);
end