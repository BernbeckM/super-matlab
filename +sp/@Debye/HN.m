function output = HN(b, omega)
    omega = omega .* 2 * pi;
    output = (b(4) - b(5)) ./ power(1 + power(1i .* omega .* b(1), b(2)), b(3));
end