function plot(obj)
    plot(1 ./ obj.model_data.Temperature, log(obj.model_data.tau));
end