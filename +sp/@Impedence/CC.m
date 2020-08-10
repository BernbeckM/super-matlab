function output = CC(b, omega)
    omega = omega .* 2 * pi;
    output = (b(3) - b(4)) ./ (1 + power(1i .* omega .* b(1), 1 - b(2)));
end