function fit(obj, varargin)
    FitOpts = optimoptions('lsqcurvefit', 'Algorithm', 'trust-region-reflective', 'Display', 'off');

    p = inputParser;
    validLogical = @(x) islogical(x);
    p.addParameter('orbach', 1, validLogical);
    p.addParameter('raman', 0, validLogical);
    p.addParameter('qtm', 0, validLogical);
    p.parse(varargin{:})

    obj.fits = [];
    obj.model_data = [];

    if ~(p.Results.orbach) && ~(p.Results.raman) && ~(p.Results.raman)
        disp('compound unable to RELAX')
        return;
    end

    orbachx0 = [1, 1]; ramanx0 = [5E-1, 9]; qtmx0 = [1E-4];
    orbachlb = [0.1, 1E-2]; ramanlb = [1E-8, 5]; qtmlb = [1E-6];
    orbachub = [30, 1E3]; ramanub = [1E-1, 9.5]; qtmub = [1E4];

    %orbachx0 = [150, 1E-10]; ramanx0 = [5E-5, 5]; qtmx0 = [1E-4];
    %orbachlb = [80, 1E-13]; ramanlb = [1E-7, 2]; qtmlb = [1E-6];
    %orbachub = [220, 1E-7]; ramanub = [1E-1, 9]; qtmub = [1E4];

    x0 = [repmat(orbachx0, 1, p.Results.orbach), repmat(ramanx0, 1, p.Results.raman), repmat(qtmx0, 1, p.Results.qtm)];
    lb = [repmat(orbachlb, 1, p.Results.orbach), repmat(ramanlb, 1, p.Results.raman), repmat(qtmlb, 1, p.Results.qtm)];
    ub = [repmat(orbachub, 1, p.Results.orbach), repmat(ramanub, 1, p.Results.raman), repmat(qtmub, 1, p.Results.qtm)];

    opts = optimoptions(@fmincon, 'Algorithm', 'interior-point', ...
                          'FunctionTolerance', 1e-30, 'OptimalityTolerance', 1e-30, 'StepTolerance', 1e-30, ...
                          'ObjectiveLimit', 1e-30, 'Display', 'off', 'ConstraintTolerance', 1E-30);
    gs = GlobalSearch('MaxTime', 45, 'Display', 'off', 'NumTrialPoints', 3500, 'NumStageOnePoints', 700);
    problem = createOptimProblem('fmincon', 'x0', x0, 'objective', @(b) sp.Relaxation.objective(obj.data.Temperature, log(1./obj.data.tau), p.Results.orbach, p.Results.raman, p.Results.qtm, b), ...
                             'lb', lb, 'ub', ub, 'options', opts);
    [obj.fits, ~, ~, ~, ~] = gs.run(problem);
    obj.fits
    xmodel = logspace(log10(min(obj.data.Temperature)), log10(max(obj.data.Temperature)), 100)';
    ymodel = sp.Relaxation.model(xmodel, p.Results.orbach, p.Results.raman, p.Results.qtm, obj.fits);
    varnames = {repmat({'Ueff', 'tau_0'}, 1, p.Results.orbach), repmat({'C', 'n'}, 1, p.Results.raman), repmat({'qtm'}, 1, p.Results.qtm)};
    obj.fits = array2table(obj.fits, 'VariableNames', [varnames{:}]);
    model_data = [xmodel, 1./ymodel];
    obj.model_data = array2table(model_data, 'VariableNames', {'Temperature', 'tau'});
end